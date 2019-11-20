import 'package:flutter/material.dart';
import '../config/index.dart';
import 'package:provide/provide.dart';
import '../provide/cart_provide.dart';
import './cart_page/cart_item.dart';
import './cart_page/cart_bottom.dart';

class CartPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(KString.cartPageTitle),//购物车
      ),
      body: FutureBuilder(
          future: _getCartInfo(context),
          builder: (context,snapshot){
            List cartList = Provide.value<CartProvide>(context).cartList;
            if(snapshot.hasData && cartList != null){

              return Stack(
                children: <Widget>[
                  Provide<CartProvide>(
                    builder: (context,child,cartProvide){
                      cartList = Provide.value<CartProvide>(context).cartList;
                      print('cartList:::' + cartList.toString());
                      return ListView.builder(
                        itemCount: cartList.length,
                          itemBuilder: (context,index){
                            return CartItem(cartList[index]);
                          }
                      );
                    },
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: CartBottom(),
                  ),

                ],
              );
            }else{
              return Text(KString.loading);//'加载中...'
            }
          }
      ),
    );
  }

  Future _getCartInfo(BuildContext context) async{
    await Provide.value<CartProvide>(context).getCartInfo();
    return 'end';
  }

}

