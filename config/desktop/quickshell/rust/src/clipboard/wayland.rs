use std::{
    collections::HashMap,
    io::{PipeReader, Read, pipe},
    iter,
    os::fd::AsFd,
};

use anyhow::{Result, bail};
use wayland_client::{
    Connection, Dispatch, EventQueue, Proxy, QueueHandle, event_created_child,
    protocol::{
        wl_registry::{self, WlRegistry},
        wl_seat::WlSeat,
    },
};
use wayland_protocols::ext::data_control::v1::client::{
    ext_data_control_device_v1::{self, ExtDataControlDeviceV1},
    ext_data_control_manager_v1::ExtDataControlManagerV1,
    ext_data_control_offer_v1::{self, ExtDataControlOfferV1},
};

#[derive(Debug)]
pub struct ClipboardListener {
    event_queue: Option<EventQueue<Self>>,
    seat: Option<WlSeat>,
    data_manager: Option<ExtDataControlManagerV1>,
    data_device: Option<ExtDataControlDeviceV1>,
    offer_mime_types: HashMap<u32, Vec<String>>,
    current_offer: Option<ExtDataControlOfferV1>,
    currently_reading: Option<(String, PipeReader)>,
}

impl ClipboardListener {
    pub fn new() -> Result<Self> {
        let connection = Connection::connect_to_env()?;

        let mut event_queue = connection.new_event_queue();
        let queue_handle = event_queue.handle();

        let display = connection.display();
        display.get_registry(&queue_handle, ());

        let mut this = Self {
            event_queue: None,
            seat: None,
            data_manager: None,
            data_device: None,
            offer_mime_types: HashMap::new(),
            current_offer: None,
            currently_reading: None,
        };
        event_queue.blocking_dispatch(&mut this)?;
        this.event_queue = Some(event_queue);

        let (Some(seat), Some(data_manager)) = (&this.seat, &this.data_manager) else {
            bail!("Couldn't get seat or data manager");
        };

        this.data_device = Some(data_manager.get_data_device(seat, &queue_handle, ()));

        Ok(this)
    }

    pub fn into_iter(mut self) -> impl Iterator<Item = Result<(String, Vec<u8>)>> {
        let mut event_queue = self
            .event_queue
            .take()
            .expect("missing event queue, this should never happen");

        iter::from_fn(move || {
            let (mime_type, mut pipe) = loop {
                if let Some(reading) = self.currently_reading.take() {
                    break reading;
                }

                if let Err(e) = event_queue.blocking_dispatch(&mut self) {
                    return Some(Err(e.into()));
                }
            };

            // See https://docs.rs/wayland-clipboard-listener/0.6.1/src/wayland_clipboard_listener/lib.rs.html#409
            if let Err(e) = event_queue.flush() {
                return Some(Err(e.into()));
            }

            let mut buffer = Vec::new();
            if let Err(e) = pipe.read_to_end(&mut buffer) {
                return Some(Err(e.into()));
            }

            Some(Ok((mime_type, buffer)))
        })
    }

    fn handle_selection(&mut self) {
        const IMAGE_TYPES: &[&str] = &[
            "image/svg",
            "image/png",
            "image/jxl",
            "image/webp",
            "image/avif",
            "image/jpeg",
        ];
        const TEXT_TYPES: &[&str] = &[
            "text/plain;charset=utf-8",
            "UTF8_STRING",
            "text/plain",
            "STRING",
        ];

        if let Some(offer) = &self.current_offer {
            let Some(mime_types) = self.offer_mime_types.get(&offer.id().protocol_id()) else {
                println!("Missing mime types for offer: {}", offer.id().protocol_id());
                return;
            };

            if mime_types.iter().any(|x| x == "x-kde-passwordManagerHint") {
                return;
            }

            let mime_type = if let Some(mime_type) = mime_types
                .iter()
                .find(|mime_type| mime_type.starts_with("image/"))
            {
                println!(
                    "Image available in the following formats: {}",
                    mime_types.join(", ")
                );

                *IMAGE_TYPES
                    .iter()
                    .find(|mime_type| mime_types.iter().any(|x| x == *mime_type))
                    .unwrap_or(&mime_type.as_str())
            } else if mime_types.iter().any(|x| x == "text/uri-list") {
                "text/uri-list"
            } else if let Some(mime_type) = TEXT_TYPES
                .iter()
                .find(|mime_type| mime_types.iter().any(|x| x == *mime_type))
            {
                *mime_type
            } else if !mime_types.is_empty() {
                println!(
                    "No compatible MIME type found in: {}`",
                    mime_types.join(", ")
                );
                return;
            } else {
                return;
            };

            let (rx, tx) = pipe().expect("couldn't create pipe");
            offer.receive(mime_type.to_owned(), tx.as_fd());

            self.currently_reading = Some((mime_type.to_owned(), rx));
        }
    }
}

impl Dispatch<WlRegistry, ()> for ClipboardListener {
    fn event(
        state: &mut Self,
        registry: &WlRegistry,
        event: <WlRegistry as Proxy>::Event,
        _data: &(),
        _connection: &Connection,
        queue_handle: &QueueHandle<Self>,
    ) {
        if let wl_registry::Event::Global {
            name,
            interface,
            version,
        } = event
        {
            if interface == WlSeat::interface().name {
                state.seat = Some(registry.bind::<WlSeat, _, _>(name, version, queue_handle, ()));
            } else if interface == ExtDataControlManagerV1::interface().name {
                state.data_manager = Some(registry.bind::<ExtDataControlManagerV1, _, _>(
                    name,
                    version,
                    queue_handle,
                    (),
                ));
            }
        }
    }
}

impl Dispatch<WlSeat, ()> for ClipboardListener {
    fn event(
        _state: &mut Self,
        _proxy: &WlSeat,
        _event: <WlSeat as Proxy>::Event,
        _data: &(),
        _connection: &Connection,
        _queue_handle: &QueueHandle<Self>,
    ) {
    }
}

impl Dispatch<ExtDataControlManagerV1, ()> for ClipboardListener {
    fn event(
        _state: &mut Self,
        _proxy: &ExtDataControlManagerV1,
        _event: <ExtDataControlManagerV1 as Proxy>::Event,
        _data: &(),
        _connection: &Connection,
        _queue_handle: &QueueHandle<Self>,
    ) {
    }
}

impl Dispatch<ExtDataControlDeviceV1, ()> for ClipboardListener {
    fn event(
        state: &mut Self,
        _proxy: &ExtDataControlDeviceV1,
        event: <ExtDataControlDeviceV1 as Proxy>::Event,
        _data: &(),
        _connection: &Connection,
        queue_handle: &QueueHandle<Self>,
    ) {
        match event {
            ext_data_control_device_v1::Event::Selection { id: offer } => {
                if let Some(offer) = state.current_offer.take() {
                    state.offer_mime_types.remove(&offer.id().protocol_id());
                    offer.destroy();
                }

                state.current_offer = offer;
                state.handle_selection();
            }
            ext_data_control_device_v1::Event::Finished => {
                if let Some(offer) = state.current_offer.take() {
                    offer.destroy();
                }
                if let Some(device) = state.data_device.take() {
                    device.destroy();
                }
                state.offer_mime_types.clear();

                if let (Some(seat), Some(data_manager)) = (&state.seat, &state.data_manager) {
                    state.data_device = Some(data_manager.get_data_device(seat, queue_handle, ()));
                }
            }
            ext_data_control_device_v1::Event::DataOffer { id: offer } => {
                state
                    .offer_mime_types
                    .entry(offer.id().protocol_id())
                    .or_default();
            }
            ext_data_control_device_v1::Event::PrimarySelection { id: Some(offer) } => {
                state.offer_mime_types.remove(&offer.id().protocol_id());
            }
            _ => (),
        }
    }

    event_created_child!(ClipboardListener, ExtDataControlDeviceV1, [
        ext_data_control_device_v1::EVT_DATA_OFFER_OPCODE => (ExtDataControlOfferV1, ())
    ]);
}

impl Dispatch<ExtDataControlOfferV1, ()> for ClipboardListener {
    fn event(
        state: &mut Self,
        proxy: &ExtDataControlOfferV1,
        event: <ExtDataControlOfferV1 as Proxy>::Event,
        _data: &(),
        _conn: &Connection,
        _qhandle: &QueueHandle<Self>,
    ) {
        if let ext_data_control_offer_v1::Event::Offer { mime_type } = event {
            state
                .offer_mime_types
                .entry(proxy.id().protocol_id())
                .or_default()
                .push(mime_type);
        }
    }
}
