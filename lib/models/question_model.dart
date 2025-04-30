// this file defines a class for how the questions and answers will be formated

class Question {
  final String questionText;
  final List<Answer> answers;

  // a constructor for null safety
  Question({
    required this.questionText,
    required this.answers,
  });
}

class Answer {
  final String answerText;
  final int points;

  // a constructor for null safety
  Answer({
    required this.answerText,
    required this.points,
  });
}
