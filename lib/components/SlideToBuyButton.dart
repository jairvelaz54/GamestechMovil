
import 'package:flutter/material.dart';

class SlideToBuyButton extends StatefulWidget {
  final double price;
  final VoidCallback onBuy;

  const SlideToBuyButton({
    Key? key,
    required this.price,
    required this.onBuy,
  }) : super(key: key);

  @override
  _SlideToBuyButtonState createState() => _SlideToBuyButtonState();
}

class _SlideToBuyButtonState extends State<SlideToBuyButton> {
  double sliderPosition = 0;
  final double sliderWidth = 300;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: sliderWidth,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Texto estático
          Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: sliderPosition >= sliderWidth - 70 ? 0.0 : 1.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "\$${widget.price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    "Desliza para comprar",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Control deslizante
          Positioned(
            left: sliderPosition,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  sliderPosition = (sliderPosition + details.delta.dx)
                      .clamp(0.0, sliderWidth - 60);
                });
              },
              onHorizontalDragEnd: (details) {
                if (sliderPosition >= sliderWidth - 70) {
                  widget.onBuy();
                  setState(() {
                    sliderPosition = 0; // Reset slider
                  });
                } else {
                  setState(() {
                    sliderPosition = 0; // Reset slider
                  });
                }
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          // Texto de "Confirmación"
          Positioned(
            right: 2,
            top: 18,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: sliderPosition >= sliderWidth - 70 ? 1.0 : 0.0,
              child: const Text(
                "Confirmando Compra",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
