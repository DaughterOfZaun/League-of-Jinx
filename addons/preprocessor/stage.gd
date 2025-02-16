class_name PreprocessorStage

var classes: Array[ClassRepr]
var named_classes: Dictionary[String, ClassRepr]
func process(classes: Array[ClassRepr], named_classes: Dictionary[String, ClassRepr]) -> void:
	self.classes = classes
	self.named_classes = named_classes
	for cls in classes:
		process_class(cls)

func process_class(_cls: ClassRepr) -> void:
	pass
