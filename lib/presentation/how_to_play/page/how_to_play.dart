import 'package:ben_kimim/core/configs/assets/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HowToPlayPage extends StatelessWidget {
  const HowToPlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Nasıl Oynanır?",
          style: TextStyle(fontSize: 30.sp),
        ),
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        // ),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 40.h, 16.w, 16.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InstructionItem(
              description:
                  "  Oynamak istediğin desteyi seç. Telefonu alnına yerleştir. Arkadaşların, deste açıklamasına göre anlatsın, canlandırsın ya da mırıldansın. Sen de kelimeyi tahmin et!",
              imagePath: AppImages.game,
            ),
            SizedBox(height: 40.h),
            InstructionItem(
              description:
                  "  Kelimeyi doğru bilirsen telefonun ekranını aşağı doğru çevir.",
              imagePath: AppImages.correct,
            ),
            SizedBox(height: 40.h),
            InstructionItem(
              description:
                  "  Pas geçmek için telefonun ekranını yukarı doğru çevir.",
              imagePath: AppImages.pass,
            ),
          ],
        ),
      ),
    );
  }
}

class InstructionItem extends StatelessWidget {
  final String description;
  final String imagePath;

  const InstructionItem({
    super.key,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset(
            imagePath,
            width: 100.h,
            height: 100.h,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(width: 18.w),
        Expanded(
          child: Text(
            description,
            style: TextStyle(
              fontSize: 16.sp,
              height: 1.5.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
