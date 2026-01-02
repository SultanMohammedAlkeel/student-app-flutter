import 'dart:convert';

class ExamRecord {
  final int id;
  final int examId;
  final int studentId;
  final double score;
  final int correct;
  final int wrong;
  final List<QuestionAnswer> answers;
  final String createdAt;
  final String updatedAt;

  ExamRecord({
    required this.id,
    required this.examId,
    required this.studentId,
    required this.score,
    required this.correct,
    required this.wrong,
    required this.answers,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExamRecord.fromJson(Map<String, dynamic> json) {
    // معالجة حقل الإجابات الذي قد يكون سلسلة نصية JSON أو قائمة مباشرة
    List<QuestionAnswer> parsedAnswers = [];
    
    if (json['answers'] != null) {
      try {
        // إذا كان حقل الإجابات سلسلة نصية JSON
        if (json['answers'] is String) {
          final List<dynamic> answersData = jsonDecode(json['answers']);
          parsedAnswers = answersData
              .map((answerJson) => QuestionAnswer.fromJson(answerJson))
              .toList();
        } 
        // إذا كان حقل الإجابات قائمة مباشرة
        else if (json['answers'] is List) {
          parsedAnswers = (json['answers'] as List)
              .map((answerJson) => QuestionAnswer.fromJson(answerJson))
              .toList();
        }
      } catch (e) {
        print('خطأ في تحليل الإجابات: $e');
      }
    }

    // معالجة حقل النتيجة الذي قد يكون رقمًا أو سلسلة نصية
    double parsedScore = 0.0;
    if (json['score'] != null) {
      if (json['score'] is double) {
        parsedScore = json['score'];
      } else if (json['score'] is int) {
        parsedScore = (json['score'] as int).toDouble();
      } else if (json['score'] is String) {
        parsedScore = double.tryParse(json['score']) ?? 0.0;
      }
    }

    return ExamRecord(
      id: json['id'] ?? 0,
      examId: json['exam_id'] ?? 0,
      studentId: json['student_id'] ?? 0,
      score: parsedScore,
      correct: json['correct'] ?? 0,
      wrong: json['wrong'] ?? 0,
      answers: parsedAnswers,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exam_id': examId,
      'student_id': studentId,
      'score': score,
      'correct': correct,
      'wrong': wrong,
      'answers': answers.map((answer) => answer.toJson()).toList(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() {
    return 'ExamRecord(id: $id, examId: $examId, score: $score, correct: $correct, wrong: $wrong)';
  }
}

class QuestionAnswer {
  final int questionIndex;
  final String question;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final String? questionType; // إضافة نوع السؤال (اختيارات أو صح وخطأ)
  final List<String>? options; // إضافة خيارات السؤال للأسئلة متعددة الخيارات

  QuestionAnswer({
    required this.questionIndex,
    required this.question,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    this.questionType,
    this.options,
  });

  factory QuestionAnswer.fromJson(Map<String, dynamic> json) {
    // تحديد نوع السؤال بناءً على البيانات المتاحة
    String? type;
    List<String>? optionsList;
    
    // محاولة تحديد نوع السؤال من البيانات
    if (json['question_type'] != null) {
      type = json['question_type'];
    } else {
      // تخمين نوع السؤال بناءً على الإجابة الصحيحة
      final correctAns = json['correct_answer']?.toString() ?? '';
      if (correctAns == 'صح' || correctAns == 'خطأ' || 
          correctAns == 'true' || correctAns == 'false') {
        type = 'صح و خطأ';
      } else {
        type = 'اختيارات';
      }
    }
    
    // استخراج الخيارات إذا كانت متوفرة
    if (json['options'] != null) {
      if (json['options'] is List) {
        optionsList = (json['options'] as List).map((e) => e.toString()).toList();
      } else if (json['options'] is String) {
        try {
          final List<dynamic> optionsData = jsonDecode(json['options']);
          optionsList = optionsData.map((e) => e.toString()).toList();
        } catch (e) {
          print('خطأ في تحليل الخيارات: $e');
        }
      }
    }

    return QuestionAnswer(
      questionIndex: json['question_index'] ?? 0,
      question: json['question'] ?? '',
      userAnswer: json['user_answer'] ?? '',
      correctAnswer: json['correct_answer'] ?? '',
      isCorrect: json['is_correct'] ?? false,
      questionType: type,
      options: optionsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_index': questionIndex,
      'question': question,
      'user_answer': userAnswer,
      'correct_answer': correctAnswer,
      'is_correct': isCorrect,
      'question_type': questionType,
      'options': options,
    };
  }
}
