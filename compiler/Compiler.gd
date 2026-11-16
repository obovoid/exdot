@tool
class_name ExdotCompiler
extends RefCounted

"""
Planned Structure:
compiler/
├── frontend/
│   ├── token.gd
│   ├── tokenizer.gd
│   ├── parser.gd
│   └── ast.gd
│
├── semantic/
│   ├── analyzer.gd
│   ├── symbol.gd
│   ├── datatype.gd
│   ├── scope.gd
│   └── module.gd
│
├── lowering/
│   ├── transformer.gd
│   └── passes/
│
├── backend/
│   └── codegen.gd
│
├── diagnostics/
│   └── diagnostic.gd
│
└── compiler.gd
"""

var tokenizer : ExdotTokenizer

func tokenize_file(filepath: String) -> void:
	print("tokenizing file:", filepath)
	var source_file = FileAccess.open(filepath, FileAccess.READ)
	
	if source_file == null:
		ExdotConsole.error("Failed to open file: %s" % source_file.get_open_error())
		return
	
	tokenizer = ExdotTokenizer.new(source_file.get_file_as_string(filepath))
	while true:
		var token := tokenizer.scan_token()
		var token_name : String = ExdotToken.Type.keys()[token.type]
		ExdotConsole.echo(["[" + token_name + "/" + str(token.type) + "]", " [lexeme] ", token.lexeme, " [literal] ", token.literal])
		if token.type == ExdotToken.Type.EOF:
			break
	source_file.close()

func generate_tokens_from_string(code: String) -> Array[ExdotToken]:
	tokenizer = ExdotTokenizer.new(code)
	var result := []
	while true:
		var token = tokenizer.scan_token()
		result.append(token)
		if token.type == ExdotToken.Type.EOF:
			break
	
	return result

func _init() -> void:
	if ExdotConsole.is_command_registered("build"):
		return
	
	ExdotConsole.register_command(
		"build",
		build,
		"Builds all source files. Behavior can be overwritten with displayed arguments.",
		[
			{
				"name": "file",
				"type": TYPE_STRING
			},
		], 0, -1
	)

func build_all() -> void:
	var source_directory := DirAccess.open(
		EXDOT.r_path("SOURCE")
	)
	if source_directory == null:
		ExdotConsole.error("Build failed. Source directory could not be opened! %s" % source_directory.get_open_error())
		return
	source_directory.include_hidden = true
	source_directory.list_dir_begin()
	for file: String in source_directory.get_files():
		var extension = file.get_extension()
		if extension != "exdot": continue
		tokenize_file(source_directory.get_current_dir() + "/" + file)

func build(files: Array = []) -> void:
	if files.size() == 0:
		return build_all()
	
	for file in files:
		var extension = file.get_extension()
		if extension != "exdot":
			ExdotConsole.error("Failed to build file '%s'. File must be a EXDOT file!" % file)
			return
		
		tokenize_file(file)
