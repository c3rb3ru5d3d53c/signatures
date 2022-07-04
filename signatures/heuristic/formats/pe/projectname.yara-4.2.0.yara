rule heuristic_pe_default_project_name_0 {
	meta:
		author      = "c3rb3ru5d3d53c"
		description = "HEURISTIC Binary Default Project Name"
		hash        = "09bb6b01db8b2177779d90c5444d91859994a1c2e907e5b444d6f6e67d2cfcfe"
		reference   = "https://c3rb3ru5d3d3d53c.io"
		created     = "2022-06-29"
		os          = "windows"
		tlp         = "white"
		rev         = 1
	strings:
		$project_name_0 = "NewProject_" ascii wide
	condition:
		uint16(0) == 0x5a4d and
        uint32(uint32(0x3c)) == 0x00004550 and
        any of ($project_name_*)
}
