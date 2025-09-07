import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController promptController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('Gemini Clone')),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/droplet.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
              child: Text(
                'Gemini Clone',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 8, 33, 54),
                ),
              ),
            ),
            Expanded(child: ListView()),
            Container(
              // color: Colors.blueAccent,
              // height: 20,
              padding: EdgeInsets.all(10.w),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: promptController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.w),
                        ),
                        fillColor: Colors.blue.shade200,
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                          borderRadius: BorderRadius.circular(100.w),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  CircleAvatar(
                    
                    radius: 8.w,
                    backgroundColor: Colors.blue.shade200,
                    child: IconButton(
                      focusColor: Theme.of(context).primaryColor,
                      icon: Icon(Icons.send, color: Colors.white, size: 7.w),
                      onPressed: () {
                        // Handle send action
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
