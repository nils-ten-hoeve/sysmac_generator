[//]: # (This file was generated from: doc/template/README.mdt using the documentation_builder package on: 2022-03-22 15:01:37.203224.)
<a id='doc-template-badges-mdt'></a>[![Code Repository](https://img.shields.io/badge/repository-git%20hub-informational)](https://github.com/nils-ten-hoeve/sysmac_generator)
[![Github Wiki](https://img.shields.io/badge/documentation-wiki-informational)](https://github.com/nils-ten-hoeve/sysmac_generator/wiki)
[![GitHub Stars](https://img.shields.io/github/stars/nils-ten-hoeve/sysmac_generator)](https://github.com/nils-ten-hoeve/sysmac_generator/stargazers)
[![GitHub License](https://img.shields.io/badge/license-MIT-informational)](https://raw.githubusercontent.com/nils-ten-hoeve/sysmac_generator/main/LICENSE)
[![GitHub Issues](https://img.shields.io/github/issues/nils-ten-hoeve/sysmac_generator)](https://github.com/nils-ten-hoeve/sysmac_generator/issues)
[![GitHub Pull Requests](https://img.shields.io/github/issues-pr/nils-ten-hoeve/sysmac_generator)](https://github.com/nils-ten-hoeve/sysmac_generator/pulls)

<a id='doc-template-01-sysmac-generator-mdt'></a><a id='sysmac-generator'></a>
# Sysmac Generator
sysmac_generator is a command line tool to help you as a developer to do tedious
tasks with [Omron Sysmac projects](https://automation.omron.com/en/us/products/family/sysstdio).

It generates files by reading [SysmacProjectFile](https://github.com/nils-ten-hoeve/sysmac_generator/wiki/01-Sysmac-Generator#sysmac-project-file)s and [TemplateFile](https://github.com/nils-ten-hoeve/sysmac_generator/wiki/01-Sysmac-Generator#template-files)s.
These files can than be used to import into Sysmac or other programs.


<a id='sysmac-project-file'></a>
# Sysmac Project File
A [SysmacProjectFile](https://github.com/nils-ten-hoeve/sysmac_generator/wiki/01-Sysmac-Generator#sysmac-project-file) is an exported
[Omron Sysmac project](https://automation.omron.com/en/us/products/family/sysstdio).
This is a file with the *.scm file extension.

Note that you need to export the
[Omron Sysmac project](https://automation.omron.com/en/us/products/family/sysstdio)
before using it with [SysmacGenerator](https://github.com/nils-ten-hoeve/sysmac_generator/wiki/01-Sysmac-Generator#sysmac-generator).

A [SysmacProjectFile](https://github.com/nils-ten-hoeve/sysmac_generator/wiki/01-Sysmac-Generator#sysmac-project-file) name should have the following format:\
&lt;site number&gt;DE&lt;panel number&gt;-&lt;panel name&gt;-&lt;standard version&gt;-&lt;customer version&gt;&lt;not installed reason&gt;.smc2\
e.g.: 4321DE06-Evisceration-001-005-to_be_installed.smc2
* &lt;site number&gt;= Meyn layout number
* &lt;panel number&gt;= Unique number within site (see electrical schematic)
* &lt;panel name&gt;= See official product name on web site (without line number!)
* &lt;standard version&gt;= 0-...
* &lt;customer version&gt;= 0-..., increases with 1 with every new version.
* &lt;not installed reason&gt;= optional text explaining why this version is not the latest version at the customer.


<a id='template-files'></a>
# Template Files
[TemplateFile](https://github.com/nils-ten-hoeve/sysmac_generator/wiki/01-Sysmac-Generator#template-files) files are text files such as:
* [csv files](https://en.wikipedia.org/wiki/Comma-separated_values)
* [json files](https://en.wikipedia.org/wiki/JSON)
* [xml files](https://en.wikipedia.org/wiki/XML)
* [text files](https://en.wikipedia.org/wiki/Text_file)
* etc...

[TemplateFile](https://github.com/nils-ten-hoeve/sysmac_generator/wiki/01-Sysmac-Generator#template-files) files can contain [TemplateTag](https://github.com/nils-ten-hoeve/sysmac_generator/wiki/01-Sysmac-Generator#template-tags)s.
The [SysmacGenerator](https://github.com/nils-ten-hoeve/sysmac_generator/wiki/01-Sysmac-Generator#sysmac-generator):
* reads these template file(s)
* does something with the [TemplateTag](https://github.com/nils-ten-hoeve/sysmac_generator/wiki/01-Sysmac-Generator#template-tags)s
* writes the resulting generated file(s) to disk


<a id='template-tags'></a>
## Template Tags
[TemplateFile](https://github.com/nils-ten-hoeve/sysmac_generator/wiki/01-Sysmac-Generator#template-files)s can contain [TemplateTag](https://github.com/nils-ten-hoeve/sysmac_generator/wiki/01-Sysmac-Generator#template-tags) texts.
[TemplateTag](https://github.com/nils-ten-hoeve/sysmac_generator/wiki/01-Sysmac-Generator#template-tags)s have a special meaning for the [SysmacGenerator](https://github.com/nils-ten-hoeve/sysmac_generator/wiki/01-Sysmac-Generator#sysmac-generator).
Most [TemplateTag](https://github.com/nils-ten-hoeve/sysmac_generator/wiki/01-Sysmac-Generator#template-tags)s are replaced by the [SysmacGenerator](https://github.com/nils-ten-hoeve/sysmac_generator/wiki/01-Sysmac-Generator#sysmac-generator) with generated text.

[TemplateTag](https://github.com/nils-ten-hoeve/sysmac_generator/wiki/01-Sysmac-Generator#template-tags)s:
* are surrounded by double square brackets: [[ ]]
* contain some kind of information, e.g.:
  * often start with a name or name path:
    e.g. [[importFile]] or [[project.name]]
  * may have one or more attributes after the name:
    e.g. [[importFile path='otherFile.txt']]

//TODO Tag implementations to be generated from classes