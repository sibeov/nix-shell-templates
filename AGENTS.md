# General
## Instructions
This repository contains common and often used modules in FPGA-development using VHDL.
The default standard is >= VHDL-2008.

## Review
When reviewing modules, source-files and similar, always:
- Point out potential flaws and logical bugs
- Point out bad practices
- Highlight if something could be done mer readable for future developers

### Specifications
- Never use AI-generated content as source/reference
- Always use best practices for "How to ... " prompts
- Always refer to best, latest, modern pracitces/solutions with regards to the versions of tools stated in:
	- `./pyproject.toml`
	- `./flake.nix`
- Always prompt if you want to rewrite / make changes to source files
- Always do atomic commits and follow the historical commit message style