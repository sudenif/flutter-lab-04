/// Этот репозиторий содержит только лабораторную работу 4.
enum LabStage { lab4 }

extension LabStageFeatures on LabStage {
  bool get usesApiList => true;
  bool get usesApiDetails => false;
  bool get hasDetails => true;
}
