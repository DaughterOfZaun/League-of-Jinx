class_name PreprocessorStage

func process(classes: Array[ClassRepr]) -> void:
	for cls in classes:
		process_class(cls)

func process_class(_cls: ClassRepr) -> void:
	pass
