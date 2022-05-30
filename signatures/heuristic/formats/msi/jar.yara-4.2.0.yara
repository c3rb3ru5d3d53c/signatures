rule heuristic_signed_msi_with_embedded_jar_0 {
    meta:
        author      = "c3rb3ru5d3d53c"
        description = "Signed MSI with Embedded JAR"
        hash        = "63bed40e369b76379b47818ba912ee43"
        reference   = "https://www.securityinbits.com/malware-analysis/interesting-tactic-by-ratty-adwind-distribution-of-jar-appended-to-signed-msi/"
        created     = "2020-06-30"
        os          = "windows"
        type        = "heuristic"
        tlp         = "white"
        rev         = 1
    strings:
        $msi_magic      = {D0 CF 11 E0 A1 B1 1A E1}
        $der_magic      = {30 82}
        $zip_magic      = {50 4B 03 04}
        $jar_manifest   = "META-INF/MANIFEST.MF" ascii nocase
        $zip_eocd       = {50 4b 05 06}
    condition:
        $msi_magic at 0 and
        @der_magic[1] > 8 and
        @zip_magic > @der_magic[1] + 2 and
        @jar_manifest > @zip_magic[1] + 4 and
        @zip_eocd > @jar_manifest[1] + 4
}
