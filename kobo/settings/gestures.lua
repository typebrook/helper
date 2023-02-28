-- we can read Lua syntax here!
return {
    ["custom_multiswipes"] = {},
    ["gesture_fm"] = {
        ["hold_bottom_left_corner"] = {
            ["history"] = true,
            ["settings"] = {
                ["order"] = {
                    [1] = "history",
                },
            },
        },
        ["hold_bottom_right_corner"] = {
            ["settings"] = {
                ["order"] = {
                    [1] = "suspend",
                },
            },
            ["suspend"] = true,
        },
        ["hold_top_left_corner"] = {
            ["exit"] = true,
            ["settings"] = {
                ["order"] = {
                    [1] = "exit",
                },
            },
        },
        ["hold_top_right_corner"] = {
            ["settings"] = {
                ["order"] = {
                    [1] = "terminal",
                },
            },
            ["terminal"] = true,
        },
        ["multiswipe"] = {},
        ["multiswipe_east_north"] = {
            ["history"] = true,
        },
        ["multiswipe_east_north_west"] = {},
        ["multiswipe_east_north_west_east"] = {},
        ["multiswipe_east_south"] = {
            ["go_to"] = true,
        },
        ["multiswipe_east_south_west_north"] = {
            ["full_refresh"] = true,
        },
        ["multiswipe_east_west"] = {},
        ["multiswipe_east_west_east"] = {
            ["favorites"] = true,
        },
        ["multiswipe_north_east"] = {},
        ["multiswipe_north_south"] = {
            ["folder_up"] = true,
        },
        ["multiswipe_north_south_north"] = {},
        ["multiswipe_north_west"] = {
            ["folder_shortcuts"] = true,
        },
        ["multiswipe_northwest_southwest_northwest"] = {
            ["toggle_wifi"] = true,
        },
        ["multiswipe_south_east"] = {},
        ["multiswipe_south_east_north"] = {},
        ["multiswipe_south_east_north_south"] = {},
        ["multiswipe_south_north"] = {},
        ["multiswipe_south_north_south"] = {},
        ["multiswipe_south_west"] = {
            ["show_frontlight_dialog"] = true,
        },
        ["multiswipe_southeast_northeast"] = {},
        ["multiswipe_southeast_northeast_northwest"] = {
            ["wifi_on"] = true,
        },
        ["multiswipe_southeast_southwest_northwest"] = {
            ["wifi_off"] = true,
        },
        ["multiswipe_west_east"] = {},
        ["multiswipe_west_east_west"] = {
            ["open_previous_document"] = true,
        },
        ["multiswipe_west_north"] = {},
        ["multiswipe_west_south"] = {
            ["back"] = true,
        },
        ["one_finger_swipe_right_edge_down"] = {
            ["full_refresh"] = true,
            ["settings"] = {
                ["order"] = {
                    [1] = "full_refresh",
                },
            },
        },
        ["one_finger_swipe_right_edge_up"] = {
            ["full_refresh"] = true,
            ["settings"] = {
                ["order"] = {
                    [1] = "full_refresh",
                },
            },
        },
        ["pinch_gesture"] = {
            ["folder_up"] = true,
            ["settings"] = {
                ["order"] = {
                    [1] = "folder_up",
                },
            },
        },
        ["short_diagonal_swipe"] = {
            ["settings"] = {
                ["order"] = {
                    [1] = "show_menu",
                },
            },
            ["show_menu"] = true,
        },
        ["spread_gesture"] = {
            ["open_previous_document"] = true,
            ["settings"] = {
                ["order"] = {
                    [1] = "open_previous_document",
                },
            },
        },
        ["tap_left_bottom_corner"] = {
            ["settings"] = {
                ["order"] = {
                    [1] = "show_frontlight_dialog",
                },
            },
            ["show_frontlight_dialog"] = true,
        },
        ["two_finger_swipe_east"] = {
            ["settings"] = {
                ["order"] = {
                    [1] = "toggle_wifi",
                },
            },
            ["toggle_wifi"] = true,
        },
        ["two_finger_swipe_north"] = {
            ["settings"] = {
                ["order"] = {
                    [1] = "show_network_info",
                },
            },
            ["show_network_info"] = true,
        },
        ["two_finger_swipe_south"] = {
            ["reboot"] = true,
            ["settings"] = {
                ["order"] = {
                    [1] = "reboot",
                },
            },
        },
        ["two_finger_swipe_west"] = {
            ["settings"] = {
                ["order"] = {
                    [1] = "toggle_ssh_server",
                },
            },
            ["toggle_ssh_server"] = true,
        },
    },
    ["gesture_reader"] = {
        ["double_tap_left_side"] = {
            ["page_jmp"] = -10,
        },
        ["double_tap_right_side"] = {
            ["page_jmp"] = 10,
        },
        ["hold_bottom_left_corner"] = {
            ["history"] = true,
            ["settings"] = {
                ["order"] = {
                    [1] = "history",
                },
            },
        },
        ["hold_bottom_right_corner"] = {
            ["settings"] = {
                ["order"] = {
                    [1] = "suspend",
                },
            },
            ["suspend"] = true,
        },
        ["hold_top_left_corner"] = {
            ["screenshot"] = true,
            ["settings"] = {
                ["order"] = {
                    [1] = "screenshot",
                },
            },
        },
        ["hold_top_right_corner"] = {
            ["book_info"] = true,
            ["settings"] = {
                ["order"] = {
                    [1] = "book_info",
                },
            },
        },
        ["multiswipe"] = {},
        ["multiswipe_east_north"] = {
            ["history"] = true,
        },
        ["multiswipe_east_north_west"] = {
            ["zoom"] = "contentwidth",
        },
        ["multiswipe_east_north_west_east"] = {
            ["zoom"] = "pagewidth",
        },
        ["multiswipe_east_south"] = {
            ["go_to"] = true,
        },
        ["multiswipe_east_south_west_north"] = {
            ["full_refresh"] = true,
        },
        ["multiswipe_east_west"] = {
            ["latest_bookmark"] = true,
        },
        ["multiswipe_east_west_east"] = {
            ["favorites"] = true,
        },
        ["multiswipe_north_east"] = {
            ["toc"] = true,
        },
        ["multiswipe_north_south"] = {},
        ["multiswipe_north_south_north"] = {
            ["prev_chapter"] = true,
        },
        ["multiswipe_north_west"] = {
            ["bookmarks"] = true,
        },
        ["multiswipe_northwest_southwest_northwest"] = {
            ["toggle_wifi"] = true,
        },
        ["multiswipe_south_east"] = {
            ["toggle_reflow"] = true,
        },
        ["multiswipe_south_east_north"] = {
            ["zoom"] = "contentheight",
        },
        ["multiswipe_south_east_north_south"] = {
            ["zoom"] = "pageheight",
        },
        ["multiswipe_south_north"] = {
            ["skim"] = true,
        },
        ["multiswipe_south_north_south"] = {
            ["next_chapter"] = true,
        },
        ["multiswipe_south_west"] = {
            ["show_frontlight_dialog"] = true,
        },
        ["multiswipe_southeast_northeast"] = {
            ["follow_nearest_link"] = true,
        },
        ["multiswipe_southeast_northeast_northwest"] = {
            ["wifi_on"] = true,
        },
        ["multiswipe_southeast_southwest_northwest"] = {
            ["wifi_off"] = true,
        },
        ["multiswipe_west_east"] = {
            ["previous_location"] = true,
        },
        ["multiswipe_west_east_west"] = {
            ["open_previous_document"] = true,
        },
        ["multiswipe_west_north"] = {
            ["book_status"] = true,
        },
        ["multiswipe_west_south"] = {
            ["back"] = true,
        },
        ["one_finger_swipe_right_edge_down"] = {
            ["page_browser"] = true,
            ["settings"] = {
                ["order"] = {
                    [1] = "page_browser",
                },
            },
        },
        ["one_finger_swipe_right_edge_up"] = {
            ["book_map"] = true,
            ["settings"] = {
                ["order"] = {
                    [1] = "book_map",
                },
            },
        },
        ["pinch_gesture"] = {
            ["filemanager"] = true,
            ["settings"] = {
                ["order"] = {
                    [1] = "filemanager",
                },
            },
        },
        ["short_diagonal_swipe"] = {
            ["settings"] = {
                ["order"] = {
                    [1] = "show_menu",
                },
            },
            ["show_menu"] = true,
        },
        ["spread_gesture"] = {
            ["open_previous_document"] = true,
            ["settings"] = {
                ["order"] = {
                    [1] = "open_previous_document",
                },
            },
        },
        ["tap_left_bottom_corner"] = {
            ["settings"] = {
                ["order"] = {
                    [1] = "show_frontlight_dialog",
                },
            },
            ["show_frontlight_dialog"] = true,
        },
        ["tap_top_left_corner"] = {
            ["toggle_page_flipping"] = true,
        },
        ["tap_top_right_corner"] = {
            ["toggle_bookmark"] = true,
        },
        ["two_finger_swipe_east"] = {
            ["toc"] = true,
        },
        ["two_finger_swipe_north"] = {
            ["settings"] = {
                ["order"] = {
                    [1] = "toggle_gsensor",
                },
            },
            ["toggle_gsensor"] = true,
        },
        ["two_finger_swipe_south"] = {
            ["settings"] = {
                ["order"] = {
                    [1] = "skim",
                },
            },
            ["skim"] = true,
        },
        ["two_finger_swipe_west"] = {
            ["bookmarks"] = true,
        },
    },
}
