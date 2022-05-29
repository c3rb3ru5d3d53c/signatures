rule heuristic_pe_sfx_silent_installer_0 {
     meta:
        author      = "c3rb3ru5d3d53c"
        description = "Silent Windows SFX Executable Installer"
        reference   = "https://twitter.com/ShadowChasing1/status/1259043584575025152"
	reference   = "https://twitter.com/ShadowChasing1/status/1312332155968614400"
        hash        = "8eeecc5d7d9e3fff6279f41396d74c58"
	hash        = "38f25aae82191f32c1dca902b67e1c97"
        created     = "2020-05-10"
        updated     = "2020-10-03"
        os          = "windows"
        type        = "other"
        tlp         = "white"
        rev         = 2
     strings:
        $7zip_sfx_0  = {21 40 49 6E 73 74 61 6C 6C 40 21
                       [0-256]
                       21 40 49 6E 73 74 61 6C 6C 45 6E 64 40 21}
        $winrar_sfx_0 = "Setup="
        $winrar_sfx_1 = "RAR_EXIT"
        $winrar_sfx_2 = "WinRAR self-extracting archive" wide ascii
        $7zip_sfx_gui_mode    = "GUIMode=\"2\""
        $winrar_sfx_silent_mode = "Silent=1"
     condition:
        uint16(0) == 0x5A4D and
        uint32(uint32(0x3C)) == 0x00004550 and
        (($7zip_sfx_0 and
          $7zip_sfx_gui_mode) or
          2 of ($winrar_sfx_*) and
          $winrar_sfx_silent_mode)
}
