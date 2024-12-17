class UnboardingContent {
  String image;
  String title;
  String description;
  double height;
  double width;

  UnboardingContent({
    required this.description,
    required this.image,
    required this.title,
    required this.height,
    required this.width,
  });
}

List<UnboardingContent> contents = [
  UnboardingContent(
    description: 'Select Your Desire Home Services\n                Anytime You Want',
    image: "images/screen1.png",
    title: 'Trusted Home Services,\n     Anytime, Anywhere!',
    height: 300,
    width: 400,
  ),
  UnboardingContent(
    description: 'You can pay cash on delivery and\n     Card payment is available',
    image: "images/screen2.png",
    title: 'Easy and Online Payment',
    height: 300,
    width: 400,
  ),
  UnboardingContent(
    description: 'You will never worry on having\n         leaked sink anymore ;)',
    image: "images/screen3.png",
    title: 'Sign Up our apps',
    height: 300,
    width: 400,
  ),
];
