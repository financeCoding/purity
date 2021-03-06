/**
 * author: Daniel Robinson  http://github.com/0xor1
 */

part of PurityClient;

WebSocket _ws;
InitAppView _initAppView;
Map<ObjectId, ClientModel> _models = new Map<ObjectId, ClientModel>();

typedef void InitAppView(dynamic model);

void initPurityAppView(InitAppView initAppView){
  if(_models.isNotEmpty){
    throw 'App already initialised.';
  }else{
    registerTranTypes();
    _initAppView = initAppView;
    _initSocket();
  }
}

void _initSocket(){
  _ws = new WebSocket('ws://${Uri.base.host}:${Uri.base.port}$PURITY_SOCKET_ROUTE_PATH');
  _ws.onOpen.first.then((_) =>
    _ws.onMessage.listen((msg) =>
      _handleMessage(new Transmittable.fromTranString(msg.data, (v){ if(v is ClientModel){ _processNewClientModels(v); } return v; }))));
}

void _handleMessage(Transmittable t){
  if(t is SessionInitialisedTransmission){
    _initAppView(t.model);
  }else{
    _models[t.emitter.id].emitEvent(t);
  }
}

void _processNewClientModels(ClientModel cm){
  if(!_models.containsKey(cm.id)){
    _models[cm.id] = cm;
    cm.addEventAction(InvocationEvent, (ie)=>_ws.sendString(ie.toTranString()));
  }
}