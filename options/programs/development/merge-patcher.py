import json
import sys
from pathlib import Path

import json5

mode = sys.argv[1]
inputFile = Path(sys.argv[2])
outputFile = Path(sys.argv[3])

if mode == "dark-base":
    data = json5.loads(inputFile.read_text())
    if data["extends"] != "Merge.sublime-theme":
        sys.exit(1)
    data["extends"] = "Merge Base.sublime-theme"
    outputFile.write_text(json.dumps(data))

elif mode == "replace-scheme":
    data = json5.loads(inputFile.read_text())
    if data["color_scheme"] != "Breakers.sublime-color-scheme":
        sys.exit(1)
    data["color_scheme"] = "Monokai.sublime-color-scheme"
    outputFile.write_text(json.dumps(data))

elif mode == "patch-theme":
    theme = json5.loads(inputFile.read_text())

    if theme["extends"] != "Merge Dark.sublime-theme":
        sys.exit(1)
    theme["extends"] = "Merge Dark Base.sublime-theme"

    theme["rules"].extend(
        [
            # `details_panel` cannot be themed, theme children instead
            # with `detail_panel_bg`, since the children should be transparent
            #
            # Commit details above files when a commit is selected
            # and some other spaces around things
            {
                "class": "linear_container_control",
                "parents": [{"class": "details_panel"}],
                "layer0.tint": "var(detail_panel_bg)",
                "layer0.opacity": 1.0,
            },
            # Probably overkill, but un-theme other linear_container_control we themed
            # by accident with the previous rule
            {
                "class": "linear_container_control",
                "parents": [
                    {"class": "details_panel"},
                    {"class": "linear_container_control"},
                ],
                "layer0.opacity": 0.0,
            },
            # Commit dialog (where you write the commit message) in the "Summary" tab
            {
                "class": "commit_dialog_summary_container",
                "parents": [{"class": "details_panel"}],
                "layer0.tint": "var(detail_panel_bg)",
                "layer0.opacity": 1.0,
            },
            # Commit dialog in a file tab
            {
                "class": "commit_dialog_section_container",
                "parents": [{"class": "details_panel"}],
                "layer0.tint": "var(detail_panel_bg)",
                "layer0.opacity": 1.0,
            },
            # Empty search results only contain `details_panel` without
            # a child, so we can't do anything about it
            #
            # `header` cannot be themed, theme child
            {
                "class": "linear_container_control",
                "parents": [{"class": "header"}],
                "layer0.tint": "var(header_bg)",
                "layer0.opacity": 1.0,
                # add back the padding we remove in the next rule
                "content_margin": [0, 2],
            },
            # Remove the padding between the header and the child
            {"class": "header", "content_margin": 0},
            # The Merge / Rebase / Hard Reset / Hide bar as a linear_container_control
            # that gets themed by the previous rule, but it shouldn't, un-theme it
            {
                "class": "linear_container_control",
                "parents": [{"class": "diverged_container"}],
                "layer0.opacity": 0.0,
                "content_margin": 0,
            },
        ],
    )

    outputFile.write_text(json.dumps(theme))
