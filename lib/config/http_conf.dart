// const base_url = 'http://192.168.3.5:8081/';
const base_url = "http://39.108.143.92:8081/";
// const base_url = "http://192.168.3.7:8081/";

const servicePath = {
  'getWeixinInfo': base_url + 'app/userInfo/userInfoDetails', //微信登录信息
  'queryrecommendGoods':
      base_url + 'app/goodsInfo/recommendGoodsInfoList', //获取推荐产品
  'queryAllCarousel': base_url + 'app/carouselInfo/carouselInfoList', //获取轮播图
  'queryAllClassify': base_url + 'app/goodsInfo/goodsClassifyTree', //获取产品类别
  'getHotGoods': base_url + 'app/goodsInfo/hotGoodsInfoList', //热门专区
  'queryAllClassifyByParentId':
      base_url + 'app/goodsInfo/classifyGoodsInfoList', //商品分类别的商品列表
  'queryClassifyGoods': base_url + 'app/goodsInfo/queryByGoodsId', //根据分类获取商品
  'downloadlist': base_url + 'app/channelInfo/channelInfoList', //获取下载列表
  'integralGoods': base_url + 'app/itemPoint/itemPointList', //获取积分商品
  'signInPoint': base_url + 'app/itemPoint/signInPoint', //签到
  'queryByItemPointId':
      base_url + 'app/itemPoint/queryByItemPointId/', //根据id获取积分商品详情
  'exchangePoint': base_url + 'app/itemPoint/exchangePoint', //积分兑换
};
