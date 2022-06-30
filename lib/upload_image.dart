import 'package:dio/dio.dart';

Future<Map?> uploadImage(
    {required String filename,
    required String filepath,
    required String url}) async {
  BaseOptions options = BaseOptions(
    baseUrl: "https://www.eraudit.space/api",
  );
  Dio dio = Dio(options);
  var formData = FormData.fromMap({
    'token': '\$2y\$10\$JCIYBt6fZ8s.sTDj91NO2epD3KTJu41l8zExgumDGzbng4BEpSjIS',
    'image[]': await MultipartFile.fromFile(filepath, filename: filename),
    'type': 'receipt'
  });
  print(formData.fields);
  try {
    Response response = await dio.post(
      '/process',
      data: formData,
      onSendProgress: (int sent, int total) {
        print('$sent $total');
      },
    );
    var formData_2 = FormData.fromMap({
      'token': '\$2y\$10\$JCIYBt6fZ8s.sTDj91NO2epD3KTJu41l8zExgumDGzbng4BEpSjIS',
    });
    Response response_2 = await dio.post(
        '/document/${response.data['data']}',
        data: formData_2
    );
    print(response_2.data);
    if(response_2.data['status']){
      print('_________////////////////__________');
      print(response_2.data['data']['document']['id']);
      return response_2.data['data'];
    }else{
      return {'e':'error'};
    }
  } catch (e) {
    print("Exception: $e");
  }
}
