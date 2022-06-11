# Contributing

The goal of contributing signatures to this repository to create detection with minimal false positives.

## File Naming and Structure

- All files should not contain
  - spaces
  - capital letters
- All file signature extensions should be named with the version of technology
  - `signature.suricata-6.0.5.rules`
  - `signature.yara-4.2.0.yara`
  - `signature.sigma-0.20.yml`
- Each folder containing your detection should contain the following folders if applicable
  - `pcaps/yyyy-mm-dd.pcap` - packet captures to verify detection
  - `samples.zip` - malware samples encrypted with the password `infected` to verify detection
  - `scripts/yyyy-mm-dd.py` - script to generate packet capture or reproduce behaviour for detection

| Category  | Prefix    | Description                                                  |
| --------- | --------- | ------------------------------------------------------------ |
| malware   | MALWARE   | Malicious Software                                           |
| policy    | POLICY    | Potential Policy Violation                                   |
| heuristic | HEURISTIC | Any detection approach that employs a practical method that is not guaranteed to be optimal. |
| phishing  | PHISHING  | Phishing or social engineering                               |
| riskware  | RISKWARE  | Software with a possible yet not definite risk to a host computer. |
| exploit   | EXPLOIT   | A software tool designed to take advantage of a flaw in a computer system. |
| attack    | ATTACK    | More generic than exploit and encompasses a variety of techniques. |

Each of these categories can have subcategories for signature metadata such as `malware.stealer`, `exploit.rce` etc.

## Traffic Light Protocol (TLP)

| TLP       | Usage                                                        | Sharing                                                      |
| --------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| TLP:RED   | Sources may use TLP:RED when information cannot be effectively acted upon by additional parties, and could lead to impacts on a party's privacy, reputation, or operations if misused. | Recipients may not share TLP:RED information with any parties outside of the specific exchange, meeting, or conversation in which it was originally disclosed. In the context of a meeting, for example, TLP:RED information is limited to those present at the meeting. In most circumstances, TLP:RED should be exchanged verbally or in person. |
| TLP:AMBER | Sources may use TLP:AMBER when information requires support to be effectively acted upon, yet carries risks to privacy, reputation, or operations if shared outside of the organizations involved. | Recipients may only share TLP:AMBER information with members of their own organization, and with clients or customers who need to know the information to protect themselves or prevent further harm. Sources are at liberty to specify additional intended limits of the sharing: these must be adhered to. |
| TLP:GREEN | Sources may use TLP:GREEN when information is useful for the awareness of all participating organizations as well as with peers within the broader community or sector. | Recipients may share TLP:GREEN information with peers and partner organizations within their sector or community, but not via publicly accessible channels. Information in this category can be circulated widely within a particular community. TLP:GREEN information may not be released outside of the community. |
| TLP:WHITE | Sources may use TLP:WHITE when information carries minimal or no foreseeable risk of misuse, in accordance with applicable rules and procedures for public release. | Subject to standard copyright rules, TLP:WHITE information may be distributed without restriction. |

## Suricata

This is the signature style guidelines for `suricata`.

| Category  | Classtype        |
| --------- | ---------------- |
| malware   | trojan-activity  |
| policy    | policy-violation |
| heuristic | misc-attack      |
| phishing  | successful-user  |
| riskware  | pup-activity     |
| exploit   | misc-attack      |
| attack    | misc-attack      |

```
alert http $HOME_NET any -> $EXTERNAL_NET any (
	msg:"<prefix> <your-title-here>";
    content:"POST"; http_method;
    content:"/example/example.php"; http_uri;
    reference:url, <reference-url>;
    metadata:created yyyy-mm-dd, updated yyyy-mm-dd, type <category>.<subcategory>, os <os>, tlp <tlp>;
    classtype:misc-attack;
    sid:<signature-id>;
    rev:<revision-number>;
)
```

**Additional Considerations:**

- When using `pcre` you must include a `fast_pattern`
- `created` is required with a `rev` of `1`
  - `updated` is required with a `rev` `>` `1`
- `reference` of type `url` is required
- `sid` is required, use the placeholder `1`, `2`, `3`, etc, as the person merging your detection will assign the `sid`
