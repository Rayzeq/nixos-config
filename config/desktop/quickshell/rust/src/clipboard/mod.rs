#![expect(
    clippy::unnecessary_box_returns,
    reason = "comes from cxx_qt::bridge, can't disable it directly on the `qobject` module"
)]

use base64::{Engine, prelude::BASE64_STANDARD};
use cxx_qt::{CxxQtType, Threading, ThreadingQueueError};
use cxx_qt_lib::{
    QByteArray, QColor, QHash, QHashPair_i32_QByteArray, QList, QModelIndex, QString, QVariant,
};
use magika::{ContentType, FileType, Session};
use regex::{Regex, bytes};
use reqwest::blocking::Client;
use std::{
    cmp::min,
    collections::HashMap,
    ffi::OsString,
    io::{ErrorKind, Read},
    os::unix::ffi::OsStringExt,
    path::PathBuf,
    pin::Pin,
    thread,
    time::Duration,
};
use syntect::{
    easy::HighlightLines,
    highlighting::{Color, Theme, ThemeSet},
    html::{IncludeBackground, append_highlighted_html_for_styled_line},
    parsing::{SyntaxReference, SyntaxSet},
    util::LinesWithEndings,
};
use unindent::unindent;
use url::Url;
use wl_clipboard_rs::{
    copy::{self, MimeType},
    paste::{self, ClipboardType, Seat},
};

use crate::clipboard::wayland::ClipboardListener;
use qobject::Roles;

mod wayland;

#[derive(Clone, Debug)]
pub enum TextEntry {
    Url(Url, Option<(Option<Url>, String, String)>),
    Color(QColor),
    Code(String, String, String),
    Text,
}

#[derive(Clone, Debug)]
pub enum Entry {
    Image { mime_type: String, data: Vec<u8> },
    File(Vec<PathBuf>),
    Text(String, TextEntry),
}

#[cxx_qt::bridge]
pub mod qobject {
    unsafe extern "C++Qt" {
        include!(<QtCore/QAbstractListModel>);

        #[qobject]
        type QAbstractListModel;
    }

    unsafe extern "C++" {
        include!("cxx-qt-lib/qhash.h");
        type QHash_i32_QByteArray = cxx_qt_lib::QHash<cxx_qt_lib::QHashPair_i32_QByteArray>;

        include!("cxx-qt-lib/qvariant.h");
        type QVariant = cxx_qt_lib::QVariant;

        include!("cxx-qt-lib/qlist.h");
        type QList_i32 = cxx_qt_lib::QList<i32>;

        include!("cxx-qt-lib/qmodelindex.h");
        type QModelIndex = cxx_qt_lib::QModelIndex;
    }

    #[qenum(ClipboardManager)]
    enum Roles {
        Type,

        // Content
        ImageData,
        Paths,
        // Url data
        Url,
        IsLoading,
        ImageUrl,
        Title,
        Description,

        Color,

        // Language
        Language,
        CodeLight,
        CodeDark,

        Text,
    }

    extern "RustQt" {
        #[qobject]
        #[qml_element]
        #[namespace = "clipboard"]
        #[base = QAbstractListModel]
        type ClipboardManager = super::ClipboardManagerRust;

        #[qinvokable]
        fn remove(self: Pin<&mut Self>, index: i32);

        #[qinvokable]
        fn copy(self: Pin<&mut Self>, index: i32);

        #[qinvokable]
        #[cxx_name = "checkClipboard"]
        fn check_clipboard(self: Pin<&mut Self>);

        #[qinvokable]
        #[cxx_override]
        #[cxx_name = "roleNames"]
        fn role_names(&self) -> QHash_i32_QByteArray;

        #[qinvokable]
        #[cxx_override]
        #[cxx_name = "rowCount"]
        fn row_count(&self, parent: &QModelIndex) -> i32;

        #[qinvokable]
        #[cxx_override]
        fn data(&self, index: &QModelIndex, role: i32) -> QVariant;

        #[inherit]
        #[cxx_name = "beginInsertRows"]
        unsafe fn begin_insert_rows(
            self: Pin<&mut ClipboardManager>,
            parent: &QModelIndex,
            first: i32,
            last: i32,
        );

        #[inherit]
        #[cxx_name = "endInsertRows"]
        unsafe fn end_insert_rows(self: Pin<&mut ClipboardManager>);

        #[inherit]
        #[cxx_name = "beginRemoveRows"]
        unsafe fn begin_remove_rows(
            self: Pin<&mut ClipboardManager>,
            parent: &QModelIndex,
            first: i32,
            last: i32,
        );

        #[inherit]
        #[cxx_name = "endRemoveRows"]
        unsafe fn end_remove_rows(self: Pin<&mut ClipboardManager>);

        #[inherit]
        #[cxx_name = "createIndex"]
        unsafe fn create_index(
            self: Pin<&mut ClipboardManager>,
            row: i32,
            column: i32,
        ) -> QModelIndex;

        #[qsignal]
        #[inherit]
        #[cxx_name = "dataChanged"]
        unsafe fn data_changed(
            self: Pin<&mut ClipboardManager>,
            top_left: &QModelIndex,
            bottom_right: &QModelIndex,
            roles: &QList_i32,
        );
    }

    impl cxx_qt::Threading for ClipboardManager {}
    impl cxx_qt::Constructor<()> for ClipboardManager {}
}

#[derive(Debug, Default)]
pub struct ClipboardManagerRust {
    items: Vec<Entry>,
}

impl cxx_qt::Constructor<()> for qobject::ClipboardManager {
    type BaseArguments = ();
    type InitializeArguments = ();
    type NewArguments = ();

    fn route_arguments(
        args: (),
    ) -> (
        Self::NewArguments,
        Self::BaseArguments,
        Self::InitializeArguments,
    ) {
        (args, (), ())
    }

    fn new((): ()) -> ClipboardManagerRust {
        ClipboardManagerRust::default()
    }

    fn initialize(self: Pin<&mut Self>, _arguments: Self::InitializeArguments) {
        let update_requester = self.qt_thread();

        thread::spawn(move || {
            let hex_rgba_regex =
                Regex::new("^#[0-9A-Za-z]{8}$").expect("invalid compile-time regex");
            let client = Client::new();
            let mut magika = magika::Session::new().expect("magica couldn't start");
            let syntaxes = SyntaxSet::load_defaults_newlines();
            let themes = ThemeSet::load_defaults();

            for item in ClipboardListener::new().unwrap().into_iter() {
                let (mime_type, data) = match item {
                    Ok(x) => x,
                    Err(e) => {
                        println!("Error while reading clipboard: {e}");
                        continue;
                    }
                };

                let entry = if mime_type.starts_with("image/") {
                    Entry::Image { mime_type, data }
                } else if mime_type == "text/uri-list" {
                    let paths = data.split(|x| *x == b'\n').filter(|x| !x.is_empty());
                    Entry::File(
                        paths
                            .map(|x| {
                                PathBuf::from(OsString::from_vec(
                                    x.strip_prefix(b"file://").unwrap_or(x).to_owned(),
                                ))
                            })
                            .collect(),
                    )
                } else {
                    let data = match str::from_utf8(&data) {
                        Ok(x) => x,
                        Err(e) => {
                            println!("Error while decoding utf8 clipboard data: {e}");
                            continue;
                        }
                    };

                    let trimmed = data.trim();
                    if trimmed.starts_with("http")
                        && let Ok(url) = Url::parse(trimmed)
                    {
                        let update_requester = update_requester.clone();
                        let client = client.clone();
                        let url_copy = url.clone();

                        thread::spawn(move || match fetch_website_preview(&client, &url_copy) {
                            Ok((image_url, title, description)) => {
                                match update_requester.queue(move |qtobject| {
                                    qtobject.update_url(url_copy, image_url, title, description);
                                }) {
                                    Ok(()) | Err(ThreadingQueueError::ObjectDestroyed) => (),
                                    Err(e) => panic!("couldn't update Qt object: {e}"),
                                }
                            }
                            Err((title, description)) => {
                                match update_requester.queue(move |qtobject| {
                                    qtobject.update_url(url_copy, None, title, description);
                                }) {
                                    Ok(()) | Err(ThreadingQueueError::ObjectDestroyed) => (),
                                    Err(e) => panic!("couldn't update Qt object: {e}"),
                                }
                            }
                        });

                        Entry::Text(data.to_owned(), TextEntry::Url(url, None))
                    } else if let Ok(color) = QColor::try_from(trimmed) {
                        if hex_rgba_regex.is_match(trimmed) {
                            // Qt parses color as AARRGGBB instead of RRGGBBAA, fix it
                            Entry::Text(
                                data.to_owned(),
                                TextEntry::Color(QColor::from_rgba_f(
                                    color.alpha_f(),
                                    color.red_f(),
                                    color.green_f(),
                                    color.blue_f(),
                                )),
                            )
                        } else {
                            Entry::Text(data.to_owned(), TextEntry::Color(color))
                        }
                    } else if let Some(syntax) = find_syntax(trimmed, &mut magika, &syntaxes) {
                        let end_index = trimmed.floor_char_boundary(min(5000, trimmed.len()));
                        let code = &trimmed[..end_index];
                        // first line isn't idented (because the string ws trimmed),
                        // but unindent ignores the first line so it's ok
                        let code = unindent(code);

                        let light = match highlighted_html_for_string_nobg(
                            &code,
                            &syntaxes,
                            syntax,
                            themes
                                .themes
                                .get("base16-ocean.light")
                                .expect("missing default theme"),
                        ) {
                            Ok(x) => x,
                            Err(e) => e.to_string(),
                        };
                        let dark = match highlighted_html_for_string_nobg(
                            &code,
                            &syntaxes,
                            syntax,
                            themes
                                .themes
                                .get("base16-ocean.dark")
                                .expect("missing default theme"),
                        ) {
                            Ok(x) => x,
                            Err(e) => e.to_string(),
                        };

                        Entry::Text(
                            data.to_owned(),
                            TextEntry::Code(syntax.name.clone(), light, dark),
                        )
                    } else {
                        Entry::Text(data.to_owned(), TextEntry::Text)
                    }
                };

                match update_requester.queue(move |mut qobject| {
                    qobject.as_mut().add(entry);
                }) {
                    Ok(()) => (),
                    // quickshell was reloaded
                    Err(ThreadingQueueError::ObjectDestroyed) => break,
                    Err(e) => panic!("couldn't update Qt object: {e}"),
                }
            }
        });
    }
}

impl qobject::ClipboardManager {
    pub fn role_names(&self) -> QHash<QHashPair_i32_QByteArray> {
        let mut roles = QHash::<QHashPair_i32_QByteArray>::default();
        roles.insert(Roles::Type.repr, QByteArray::from("type"));
        roles.insert(Roles::ImageData.repr, QByteArray::from("imageData"));
        roles.insert(Roles::Paths.repr, QByteArray::from("paths"));
        roles.insert(Roles::Url.repr, QByteArray::from("url"));
        roles.insert(Roles::IsLoading.repr, QByteArray::from("isLoading"));
        roles.insert(Roles::ImageUrl.repr, QByteArray::from("imageUrl"));
        // "link_" prefix to prevent a name conflict in QML side
        roles.insert(Roles::Title.repr, QByteArray::from("linkTitle"));
        roles.insert(Roles::Description.repr, QByteArray::from("description"));
        roles.insert(Roles::Color.repr, QByteArray::from("color"));
        roles.insert(Roles::Language.repr, QByteArray::from("language"));
        roles.insert(Roles::CodeLight.repr, QByteArray::from("codeLight"));
        roles.insert(Roles::CodeDark.repr, QByteArray::from("codeDark"));
        roles.insert(Roles::Text.repr, QByteArray::from("text"));
        roles
    }

    fn row_count(&self, _parent: &QModelIndex) -> i32 {
        self.items.len() as i32
    }

    pub fn data(&self, index: &QModelIndex, role: i32) -> QVariant {
        let role = qobject::Roles { repr: role };
        if let Some(item) = self.items.get(index.row() as usize) {
            match role {
                qobject::Roles::Type => {
                    return QVariant::from(&QString::from(match item {
                        Entry::Image { .. } => "image",
                        Entry::File(..) => "file",
                        Entry::Text(_, text_entry) => match text_entry {
                            TextEntry::Url(..) => "url",
                            TextEntry::Color(..) => "color",
                            TextEntry::Code(..) => "code",
                            TextEntry::Text => "text",
                        },
                    }));
                }
                qobject::Roles::ImageData => {
                    if let Entry::Image { mime_type, data } = item {
                        return QVariant::from(&QString::from(format!(
                            "data:${mime_type};base64,${}",
                            BASE64_STANDARD.encode(data)
                        )));
                    }
                }
                qobject::Roles::Paths => {
                    if let Entry::File(paths) = item {
                        return QVariant::from(&QString::from(
                            paths
                                .iter()
                                .map(|path| path.to_string_lossy())
                                .collect::<Vec<_>>()
                                .join("\n"),
                        ));
                    }
                }
                qobject::Roles::Url => {
                    if let Entry::Text(_, entry) = item
                        && let TextEntry::Url(url, _) = entry
                    {
                        return QVariant::from(&QString::from(url.to_string()));
                    }
                }
                qobject::Roles::IsLoading => {
                    if let Entry::Text(_, entry) = item
                        && let TextEntry::Url(_, data) = entry
                    {
                        return QVariant::from(&data.is_none());
                    }
                }
                qobject::Roles::ImageUrl => {
                    if let Entry::Text(_, entry) = item
                        && let TextEntry::Url(_, Some((image_url, _, _))) = entry
                    {
                        return QVariant::from(&QString::from(
                            image_url
                                .as_ref()
                                .map(ToString::to_string)
                                .unwrap_or_default(),
                        ));
                    }
                }
                qobject::Roles::Title => {
                    if let Entry::Text(_, entry) = item
                        && let TextEntry::Url(_, Some((_, title, _))) = entry
                    {
                        return QVariant::from(&QString::from(title));
                    }
                }
                qobject::Roles::Description => {
                    if let Entry::Text(_, entry) = item
                        && let TextEntry::Url(_, Some((_, _, description))) = entry
                    {
                        return QVariant::from(&QString::from(description));
                    }
                }
                qobject::Roles::Color => {
                    if let Entry::Text(_, entry) = item
                        && let TextEntry::Color(color) = entry
                    {
                        return QVariant::from(color);
                    }
                }
                qobject::Roles::Language => {
                    if let Entry::Text(_, entry) = item
                        && let TextEntry::Code(language, _, _) = entry
                    {
                        return QVariant::from(&QString::from(language));
                    }
                }
                qobject::Roles::CodeLight => {
                    if let Entry::Text(_, entry) = item
                        && let TextEntry::Code(_, markup_light, _) = entry
                    {
                        return QVariant::from(&QString::from(markup_light));
                    }
                }
                qobject::Roles::CodeDark => {
                    if let Entry::Text(_, entry) = item
                        && let TextEntry::Code(_, _, markup_dark) = entry
                    {
                        return QVariant::from(&QString::from(markup_dark));
                    }
                }
                qobject::Roles::Text => {
                    if let Entry::Text(text, entry) = item
                        && matches!(entry, TextEntry::Text)
                    {
                        return QVariant::from(&QString::from(text.trim()));
                    }
                }
                _ => (),
            }
        }

        QVariant::default()
    }

    fn add(mut self: Pin<&mut Self>, entry: Entry) {
        let parent = QModelIndex::default();

        unsafe {
            self.as_mut().begin_insert_rows(&parent, 0, 0);
            self.as_mut().rust_mut().items.insert(0, entry);
            self.as_mut().end_insert_rows();
        }

        if self.items.len() > 20 {
            let last_index = (self.items.len() - 1) as i32;
            unsafe {
                self.as_mut()
                    .begin_remove_rows(&parent, last_index, last_index);
                self.as_mut().rust_mut().items.pop();
                self.as_mut().end_remove_rows();
            }
        }
    }

    pub fn remove(mut self: Pin<&mut Self>, index: i32) {
        let index = index as usize;
        if index < self.items.len() {
            let parent = QModelIndex::default();

            unsafe {
                self.as_mut()
                    .begin_remove_rows(&parent, index as i32, index as i32);
                self.as_mut().rust_mut().items.remove(index);
                self.as_mut().end_remove_rows();
            }
        }
    }

    pub fn copy(self: Pin<&mut Self>, index: i32) {
        if let Some(entry) = self.as_ref().rust().items.get(index as usize) {
            let (mime_type, data) = match entry {
                Entry::Image { mime_type, data } => (
                    MimeType::Specific(mime_type.clone()),
                    copy::Source::Bytes(data.clone().into_boxed_slice()),
                ),
                Entry::File(paths) => (
                    MimeType::Specific("text/uri-list".to_owned()),
                    copy::Source::Bytes(Box::from(
                        paths
                            .iter()
                            .map(|path| format!("file://{}", path.display()))
                            .collect::<Vec<_>>()
                            .join("\n")
                            .as_bytes(),
                    )),
                ),
                Entry::Text(text, _) => (
                    MimeType::Text,
                    copy::Source::Bytes(Box::from(text.as_bytes())),
                ),
            };

            if let Err(e) = copy::copy(copy::Options::default(), data, mime_type) {
                println!("Error while copying to clipboard: {e}");
            }
        }
    }

    pub fn check_clipboard(self: Pin<&mut Self>) {
        let update_requester = self.qt_thread();

        thread::spawn(move || {
            thread::sleep(Duration::from_millis(500));
            if let Err(paste::Error::ClipboardEmpty) =
                paste::get_mime_types(ClipboardType::Regular, Seat::Unspecified)
            {
                match update_requester.queue(move |qobject| {
                    qobject.copy(0);
                }) {
                    Ok(()) | Err(ThreadingQueueError::ObjectDestroyed) => (),
                    Err(e) => panic!("couldn't update Qt object: {e}"),
                }
            }
        });
    }

    fn update_url(
        mut self: Pin<&mut Self>,
        url: Url,
        image_url: Option<Url>,
        title: String,
        description: String,
    ) {
        let mut index = None;
        for (i, entry) in self.as_mut().rust_mut().items.iter_mut().enumerate().rev() {
            if let Entry::Text(_, TextEntry::Url(entry_url, data @ None)) = entry
                && *entry_url == url
            {
                *data = Some((image_url, title, description));
                index = Some(i);
                break;
            }
        }

        if let Some(index) = index {
            unsafe {
                let index = self.as_mut().create_index(index as i32, 0);
                self.data_changed(
                    &index,
                    &index,
                    &QList::from(&[
                        Roles::IsLoading.repr,
                        Roles::ImageUrl.repr,
                        Roles::Title.repr,
                        Roles::Description.repr,
                    ]),
                );
            }
        }
    }
}

fn fetch_website_preview(
    client: &Client,
    url: &Url,
) -> Result<(Option<Url>, String, String), (String, String)> {
    let mut response = client
        .get(url.clone())
        .send()
        .map_err(|e| ("Error fetching preview".to_owned(), e.to_string()))?;

    let head_end_regex = bytes::RegexBuilder::new(r"</head>")
        .unicode(true)
        .case_insensitive(true)
        .build()
        .expect("builtin regex should be valid");
    let mut buffer = vec![0; 1024];
    let mut index = 0;
    loop {
        let n = match response.read(&mut buffer[index..]) {
            Ok(n) => {
                if n == 0 {
                    break;
                }
                n
            }
            Err(e) if e.kind() == ErrorKind::Interrupted => continue,
            Err(e) => {
                return Err(("Error fetching preview".to_owned(), e.to_string()));
            }
        };

        if head_end_regex.find(&buffer[index..index + n]).is_some() {
            break;
        }

        index += n;
        if index == buffer.len() {
            buffer.extend_from_slice(&[0; 1024]);
        }
    }

    let head_regex = bytes::RegexBuilder::new(r"<head[^>]*>(.*?)</head>")
        .unicode(true)
        .case_insensitive(true)
        .dot_matches_new_line(true)
        .build()
        .expect("builtin regex should be valid");

    let head = if let Some(captures) = head_regex.captures(&buffer)
        && let Some(head) = captures.get(1)
    {
        head.as_bytes()
    } else {
        return Err((
            "Nothing found".to_owned(),
            "The page didn't seem to have any content".to_owned(),
        ));
    };

    let meta_regex = bytes::RegexBuilder::new(r"<meta\s+([^>]+)>")
        .unicode(true)
        .case_insensitive(true)
        .build()
        .expect("builtin regex should be valid");
    let attr_regex = bytes::RegexBuilder::new(r#"([a-zA-Z0-9_:-]+)\s*=\s*(?:"([^"]*)"|'([^']*)')"#)
        .unicode(true)
        .case_insensitive(true)
        .build()
        .expect("builtin regex should be valid");

    let mut metadata = HashMap::new();
    for meta in meta_regex.captures_iter(head) {
        let Some(meta) = meta.get(1) else {
            continue;
        };
        let mut name = None;
        let mut property = None;
        let mut content = None;

        for attr in attr_regex.captures_iter(meta.as_bytes()) {
            let Some(attr_name) = attr
                .get(1)
                .and_then(|x| str::from_utf8(x.as_bytes()).ok())
                .map(str::to_ascii_lowercase)
            else {
                continue;
            };
            let Some(attr_value) = attr
                .get(2)
                .or_else(|| attr.get(3))
                .and_then(|x| str::from_utf8(x.as_bytes()).ok())
            else {
                continue;
            };

            if attr_name == "name" {
                name = Some(attr_value.to_owned());
            } else if attr_name == "property" {
                property = Some(attr_value.to_owned());
            } else if attr_name == "content" {
                content = Some(attr_value.to_owned());
            }
        }

        if let Some(name) = property.or(name)
            && let Some(content) = content
        {
            metadata.insert(name, content);
        }
    }

    let title = metadata
        .remove("og:title")
        .or_else(|| {
            let title_regex = bytes::RegexBuilder::new(r"<title[^>]*>(.*?)</title>")
                .unicode(true)
                .case_insensitive(true)
                .build()
                .expect("builtin regex should be valid");
            title_regex
                .captures(head)
                .and_then(|x| x.get(1))
                .and_then(|x| str::from_utf8(x.as_bytes()).ok())
                .map(ToOwned::to_owned)
        })
        .unwrap_or_default();
    let description = metadata
        .remove("og:description")
        .or_else(|| metadata.remove("description"))
        .unwrap_or_default();
    let image = metadata
        .remove("og:image")
        .and_then(|x| Url::parse(&x).ok());

    Ok((image, title, description))
}

fn highlighted_html_for_string_nobg(
    code: &str,
    syntax_set: &SyntaxSet,
    syntax: &SyntaxReference,
    theme: &Theme,
) -> Result<String, syntect::Error> {
    let mut highlighter = HighlightLines::new(syntax, theme);
    let mut output = String::new();
    let bg = theme.settings.background.unwrap_or(Color::WHITE);

    for line in LinesWithEndings::from(code) {
        let regions = highlighter.highlight_line(line, syntax_set)?;
        append_highlighted_html_for_styled_line(
            &regions[..],
            IncludeBackground::IfDifferent(bg),
            &mut output,
        )?;
    }
    Ok(output)
}

fn find_syntax<'a>(
    code: &str,
    magika: &mut Session,
    syntax_set: &'a SyntaxSet,
) -> Option<&'a SyntaxReference> {
    let magika_result = magika
        .identify_content_sync(code.as_bytes())
        .expect("magika shouldn't fail");

    let language = match magika_result {
        FileType::Directory | FileType::Symlink => return None,
        FileType::Inferred(inferred_type) => {
            if inferred_type.score > 0.3 {
                inferred_type.inferred_type
            } else {
                return None;
            }
        }
        FileType::Ruled(content_type) => content_type,
    };
    if language == ContentType::Txt {
        return None;
    }

    syntax_set.find_syntax_by_token(language.info().label)
}
