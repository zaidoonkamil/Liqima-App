import '../ navigation/navigation.dart';
import '../../features/auth/view/login.dart';
import '../network/local/cache_helper.dart';

String token='';
int classId=1;
String className='';
String id='';
String adminOrUser='' ;
String phoneWoner='7736699924' ;
String logo='logo.png' ;

void signOut(context) {
  CacheHelper.removeData(
    key: 'token',
  ).then((value)
  {
    token='';
    adminOrUser='' ;
    id='' ;
    if (value)
    {
      CacheHelper.removeData(key: 'role',);
      CacheHelper.removeData(key: 'id',);
      CacheHelper.removeData(key: 'location',);
      CacheHelper.removeData(key: 'latitude',);
      CacheHelper.removeData(key: 'longitude',);
      navigateTo(context, const Login(),);
    }
  });
}
