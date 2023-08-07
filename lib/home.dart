import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool loading = false;
  String? pickedImage;
  List<dynamic> predictions = [];
  String? label = '';
  String? confi = '0';

  @override
  void initState() {
    super.initState();
    loadModel();

  }

  loadModel() async{
    await Tflite.loadModel(model: 'assets/model_unquant.tflite',labels: 'assets/labels.txt');
  }

  detectImage(file) async{
    var prediction = await Tflite.runModelOnImage(
      path: file,
      numResults: 2,
      threshold: 0.6,
      imageMean: 127.5,
      imageStd: 127.5
    );
    setState(() {
      predictions = prediction!;
    });
  }
  
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Brain Tumor Classification",style: TextStyle(fontSize: 25)),
              SizedBox(height: 70,),
              if(pickedImage!=null)
                Container(
                  width: width * 0.7,
                  height: height * 0.35,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(File(pickedImage!)),
                      fit:BoxFit.cover
                    )
                  ),
                ),
              SizedBox(height: 20,),
              InkWell(
                child: Container(
                  width: width,
                  height: height * 0.06,
                  decoration:const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.black
                  ),
                  child: const Center(
                    child: Text("Camera",style: TextStyle(fontSize: 20,color: Colors.white),),
                  ),
                ),
                onTap: (){
                  getImageFrom(source: ImageSource.camera);
                },
              ),
              const SizedBox(height: 10,),
              InkWell(
                child: Container(
                  width: width,
                  height: height * 0.06,
                  decoration:const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.black
                  ),
                  child: const Center(
                    child: Text("Gallery",style: TextStyle(fontSize: 20,color: Colors.white),),
                  ),
                ),
                onTap: (){
                  getImageFrom(source: ImageSource.gallery);
                  setState(() {
                    label = '';
                    confi = '0';
                  });
                },
              ),
              const SizedBox(height: 20,),
              InkWell(
                child: Container(
                  width: width * 0.7,
                  height: height * 0.06,
                  decoration:const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.black
                  ),
                  child: const Center(
                    child: Text("Show results",style: TextStyle(fontSize: 20,color: Colors.white),),
                  ),
                ),
                onTap: (){
                  setState(() {
                    label = predictions[0]['label'].toString().substring(2);
                    confi = predictions[0]['confidence'].toString().substring(0,3);
                  });
                },
              ),
              
              const SizedBox(height: 25,),

              Text("Result : "+label.toString(),style:const TextStyle(fontSize: 20),),
              const SizedBox(height: 15,),
              Text("Confidence : "+confi.toString(),style: TextStyle(fontSize: 18),),
                
            ]
          ),
        ),
      ),
    );
  }

  Future<File?> getImageFrom({required ImageSource source}) async{
    final file = await ImagePicker().pickImage(source:source);
    if(file?.path != null){
      setState(() {
        pickedImage =  file!.path;
      });
      detectImage(pickedImage);
    }
  }
  

}