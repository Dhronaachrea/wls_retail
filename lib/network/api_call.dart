import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:wls_pos/network/network_utils.dart';

import '../utility/user_info.dart';
import '../utility/utils.dart';
import '../utility/wls_pos_color.dart';
import '../utility/wls_pos_screens.dart';



class CallApi {
  static Future<dynamic> callApi(String baseUrl, MethodType methodType, String relativeUrl, {String contentType = "application/json", Map<String, dynamic>? requestBody, Map<String, dynamic>?  params, Map<String, dynamic>? headers, int? pathId}) async {
    var dioObj = Dio();
    if (!await dioObj.isNetworkConnected()) {
      return {"occurredErrorDescriptionMsg": "No connection"}; // don't change msg as no internet checks is set on this msg.
    }

    dioObj.options.baseUrl = baseUrl;
    dioObj.options.connectTimeout = 30000;
    dioObj.options.receiveTimeout = 30000;

    dioObj.interceptors.add(
        LogInterceptor(
          requestBody: true,
          requestHeader: true,
          responseBody: true,
          responseHeader: true,
          logPrint: (object) {
            log(object.toString());
          },
        )
    );

    Response response;
    try {
      switch(methodType) {
        case MethodType.get : {
          params != null
              ? response = await dioObj.get(relativeUrl, queryParameters: params,
                options: Options(
                  validateStatus: (_) => true,
                    headers: headers,
                    contentType: contentType
                )
              )
              : pathId != null
                ? response = await dioObj.get("$relativeUrl/$pathId")
                : headers != null ? response = await dioObj.get(relativeUrl, options: Options(headers: headers, contentType: contentType)) : response = await dioObj.get(relativeUrl);

          break;
        }

        case MethodType.post:
          if (contentType == contentTypeMap[ContentTypeLabel.multipart]) {
            final formData = FormData.fromMap(requestBody ?? {});
            response = await dioObj.post(relativeUrl,
              options: Options(
                  validateStatus: (_) => true,
                  headers: headers,
                  contentType: contentType
              ),
              data: formData,
            );

          } else {
            params != null ?
            response = await dioObj.post(relativeUrl,
              options: Options(
                  validateStatus: (_) => true,
                  headers: headers,
                  contentType: contentType
              ),
              queryParameters: params,
              data: jsonEncode(requestBody),
            )
            :
              response = await dioObj.post(relativeUrl,
              options: Options(
              headers: headers,
              contentType: contentType
              ),
              data: jsonEncode(requestBody),
              );
          }

          break;

        case MethodType.put:
          pathId != null
              ?
          response = await dioObj.put("$relativeUrl/$pathId",
            options: Options(
                headers: headers,
                contentType: contentType
            ),
            data: jsonEncode(requestBody),
          )
              :
          response = await dioObj.put(relativeUrl,
            options: Options(
                headers: headers,
                contentType: contentType
            ),
            data: jsonEncode(requestBody),
            queryParameters: params,
          );
          break;

        case MethodType.patch:
          pathId != null
              ?
          response = await dioObj.patch("$relativeUrl/$pathId",
            options: Options(
                headers: headers,
                contentType: contentType
            ),
            data: jsonEncode(requestBody),
          )
              :
          response = await dioObj.patch(relativeUrl,
              options: Options(
                  headers: headers,
                  contentType: contentType
              ),
              data: jsonEncode(requestBody),
              queryParameters: params
          );
          break;

        case MethodType.delete:
          pathId != null
              ?
          response = await dioObj.delete("$relativeUrl/$pathId",
              options: Options(
                  headers: headers,
                  contentType: contentType
              )
          )
              :
          response = await dioObj.delete(relativeUrl,
              options: Options(
                  headers: headers,
                  contentType: contentType
              ),
              data: jsonEncode(requestBody),
              queryParameters: params
          );
          break;
      }
      if (response.statusCode == 200 && response.data != null) {

        try{
          if (response.data["responseData"].toString().contains("statusCode")) {
            if (response.data["responseData"]["statusCode"] == 102) { // session expire
              BuildContext? context = navigatorKey.currentContext;
              UserInfo.logout();
              if (context != null) {
                final Orientation orientation = MediaQuery.of(context).orientation;
                final bool isLandscape = (orientation == Orientation.landscape);
                Navigator.of(context).popUntil((route) => false);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(backgroundColor:WlsPosColor.tomato,
                      //width: MediaQuery.of(context).size.width * (isLandscape ? 0.4 : 1),
                      content: const Text("Session Expired, Please Login", style: TextStyle(color: WlsPosColor.white)),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height - 100,
                          right: 20,
                          left: 20),));
                Navigator.of(context).pushNamed(WlsPosScreen.loginScreen);
              }
            }
            return response.data;
          } else if (response.toString().contains("responseCode")){
            if(response.data["responseCode"] == 1021){ // // session expire to check scratch side only
              BuildContext? context = navigatorKey.currentContext;
              UserInfo.logout();
              if (context != null) {
                Navigator.of(context).popUntil((route) => false);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(backgroundColor:WlsPosColor.tomato,
                      content: const Text("Session Expired, Please Login", style: TextStyle(color: WlsPosColor.white)),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height - 100,
                          right: 20,
                          left: 20),));
                Navigator.of(context).pushNamed(WlsPosScreen.loginScreen);
              }
            }
            return response.data;
          }
        } catch(e) {
          print("api_call_error------->$e");
        }

        return response.data;
      } else if (response.data.toString().contains("responseCode")){
       try{
         if (response.data["responseCode"] == 401) { // session expire for sports sale
           BuildContext? context = navigatorKey.currentContext;
           UserInfo.logout();
           if (context != null) {
             final Orientation orientation = MediaQuery.of(context).orientation;
             final bool isLandscape = (orientation == Orientation.landscape);

             Navigator.of(context).popUntil((route) => false);
             ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(backgroundColor:WlsPosColor.tomato,


                   content: Text("Session Expired, Please Login", style: TextStyle(color: WlsPosColor.white, fontSize: isLandscape ? 18 : 14)),
                   behavior: SnackBarBehavior.floating,
                   duration: const Duration(seconds: 1),
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(6),
                   ),
                   margin: EdgeInsets.only(
                       bottom: MediaQuery.of(context).size.height - 100,
                       right: isLandscape ? (MediaQuery.of(context).size.width * 0.3)  : 20,
                       left: isLandscape ? (MediaQuery.of(context).size.width * 0.3)  : 20),));
             Navigator.of(context).pushNamed(WlsPosScreen.loginScreen);
           }
         }
         return response.data;
       } catch(e){
         print("api_call_error in 55 server------->$e");
       }
      }
      else if ((response.statusCode == 401 || response.statusCode == 400) && response.data != null) {
        return response.data;
      }
      else {
        return {"occurredErrorDescriptionMsg": "Might be status code is not success or response data is null"};
      }
    } on DioError catch (e) {
      if (e.type == DioErrorType.connectTimeout) {
        log("------------ DioError Exception e: connectTimeout: ${e.error} --------------");
      }
      if (e.type == DioErrorType.receiveTimeout) {
        log("------------ DioError Exception e: receiveTimeout: ${e.error} --------------");
      }
      log("------------ DioError Exception e: ${e.error} --------------");

      return {"occurredErrorDescriptionMsg": e.error};
    }
  }
}
