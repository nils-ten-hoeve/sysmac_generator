[//]: # (This file was generated from: doc/template/01-Sysmac-Generator.mdt using the documentation_builder package on: 2022-02-22 12:02:48.920655.)
<a id='sysmac-generator'></a>
# Sysmac Generator
sysmac_generator is a command line tool to help you as a developer to do tedious
tasks with [Omron Sysmac projects](https://automation.omron.com/en/us/products/family/sysstdio).

It generates files by reading [SysmacProjectFile](https://github.com/nils-ten-hoeve/sysmac_generator/wiki/01-Sysmac-Generator#sysmac-project-file)s and [TemplateFile](https://github.com/nils-ten-hoeve/sysmac_generator/wiki/01-Sysmac-Generator#template-file)s.
These files can than be used to import into Sysmac or other programs.


<a id='sysmac-project-file'></a>
# Sysmac Project File
A [SysmacProjectFile](https://github.com/nils-ten-hoeve/sysmac_generator/wiki/01-Sysmac-Generator#sysmac-project-file) is an exported
[Omron Sysmac project](https://automation.omron.com/en/us/products/family/sysstdio).
This is a file with the *.scm file extension.

Note that you need to export the
[Omron Sysmac project](https://automation.omron.com/en/us/products/family/sysstdio)
before using it with [SysmacGenerator](https://github.com/nils-ten-hoeve/sysmac_generator/wiki/01-Sysmac-Generator#sysmac-generator).


<a id='template-file'></a>
# Template File
[TemplateFile](https://github.com/nils-ten-hoeve/sysmac_generator/wiki/01-Sysmac-Generator#template-file) files are text files such as:
* [csv files](https://en.wikipedia.org/wiki/Comma-separated_values)
* [json files](https://en.wikipedia.org/wiki/JSON)
* [xml files](https://en.wikipedia.org/wiki/XML)
* [text files](https://en.wikipedia.org/wiki/Text_file)
* etc...

[TemplateFile](https://github.com/nils-ten-hoeve/sysmac_generator/wiki/01-Sysmac-Generator#template-file) files can contain [Tags] and [Variable](https://github.com/nils-ten-hoeve/sysmac_generator/wiki/01-Sysmac-Generator#variable)s.
The [SysmacGenerator](https://github.com/nils-ten-hoeve/sysmac_generator/wiki/01-Sysmac-Generator#sysmac-generator):
* reads these template file(s)
* replaces the [Tag](https://github.com/nils-ten-hoeve/sysmac_generator/wiki/01-Sysmac-Generator#tag)s and [Variables]
* writes the resulting generated file(s) to disk


<a id='tag'></a>
## Tag
TODO

//TODO Tag implementations to be generated from classes

<a id='variable'></a>
## Variable
Variable

//TODO Variable definition to be generated from classes