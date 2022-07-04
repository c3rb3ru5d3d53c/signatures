rule heuristic_xor_strings_0 {
    meta:
        author      = "c3rb3ru5d3d53c"
        description = "HEURISTIC Suspicious XOR Strings"
        reference   = "https://c3rb3ru5d3d53c.io/malware-blog/2022-07-04-bitter-apt-zxxz-backdoor"
        hash        = "f0d4d43cd6f3c33ed78d13722e81d03f21101edbc15cb0782448d0843fb2bf7f"
        created     = "2022-06-27"
        type        = "heuristic"
        os          = "windows"
        tlp         = "white"
        rev         = 1
    strings:
        $str_0 = "://"            xor
        $str_1 = "LoadLibrary"    xor
        $str_2 = "GetProcAddress" xor
        $str_3 = "ShellExecute"   xor
        $str_4 = "kernel32"       xor
    condition:
        any of ($str_*)
}
