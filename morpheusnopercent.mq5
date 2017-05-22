extern int OpenOrders = 20;
extern double lotsize = 1.0;

extern double Percentage = 0.65;
extern double TrailingStop = 0.0160;
extern double TakeProfit = 0.1200; 
extern int closeallvalue = 75000;
extern int tradeincrement = 3600;

int magic_number;

int currentbalance = 0;
int currentdate = 0;
datetime lasttrade = 0;
int lasttradelong=0;
int ticket = 0;

int init()
{
   MathSrand(TimeLocal());  
   return(0);
}

void OnTick()
{

     // if(currentdate != TimeDay(TimeCurrent())){
         //Print("AccountBalanceEURCHF3 = " + AccountBalance());
     //    currentdate= TimeDay(TimeCurrent());
     // }

      //if(AccountEquity()-AccountBalance()>closeallvalue)
    //  {
      //   closeall();
     // }
      
      if (TimeCurrent() >= lasttrade+tradeincrement)
      {
         
      if(OrdersTotal()<OpenOrders)
      {  
         
            MqlTradeRequest request={0}; 
            request.action=TRADE_ACTION_PENDING;         // setting a pending order 
            request.magic=magic_number;                  // ORDER_MAGIC 
            request.symbol=_Symbol;                      // symbol 
            request.volume=0.1;                          // volume in 0.1 lots 
            request.sl=TrailingStop;                                // Stop Loss is not specified 
            request.tp=TakeProfit;                                // Take Profit is not specified      
            //--- form the order type 
            request.type=ORDER_TYPE_BUY;                // order type 
            //--- form the price for the pending order 
            //request.price=;  // open price 
            //--- send a trade request 
            MqlTradeResult result={0}; 
         if(lasttradelong==1)
         {     
           // RefreshRates();
            
            ticket = OrderSend(request,result);
            if(ticket < 0)
            {
               Print("OrderSend Error: ", GetLastError());
            }
            else
            {
               Print("Order Sent Successfully, Ticket # is: " + string(ticket));  
            }
            lasttrade=TimeCurrent();
            lasttradelong=0;
            
         }
         if(lasttradelong==0)
         {
           // RefreshRates();
           MqlTradeRequest request={0}; 
            request.action=TRADE_ACTION_PENDING;         // setting a pending order 
            request.magic=magic_number;                  // ORDER_MAGIC 
            request.symbol=_Symbol;                      // symbol 
            request.volume=0.1;                          // volume in 0.1 lots 
            request.sl=TrailingStop;                                // Stop Loss is not specified 
            request.tp=TakeProfit;                                // Take Profit is not specified      
            //--- form the order type 
            request.type=ORDER_TYPE_SELL;                // order type 
            //--- form the price for the pending order 
            //request.price=;  // open price 
            //--- send a trade request 
            MqlTradeResult result={0}; 
            OrderSend(request,result);
            if(ticket < 0)
            {
               Print("OrderSend Error: ", GetLastError());
            }
            else
            {
               Print("Order Sent Successfully, Ticket # is: " + string(ticket));  
            }
            lasttrade=TimeCurrent();             
            lasttradelong=1;     
         }            
      }  
         
      /*for(int cnt=0;cnt<OrdersTotal();cnt++)
      {
         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
         if(Bid>OrderOpenPrice()&&OrderType()==OP_BUY)
         {
               if(OrderStopLoss()<Bid-TrailingStop)
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),Bid-TrailingStop,OrderTakeProfit(),0,Blue);
               }

         }
         
         if(Ask<OrderOpenPrice()&&OrderType()==OP_SELL)
         {
 
               if(OrderStopLoss()>Ask+TrailingStop)
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),Ask+TrailingStop,OrderTakeProfit(),0,Blue);
               }
            
         }
      }*/
   }

}
