//+------------------------------------------------------------------+
//|                                                   Shuka v1.6.mq4 |
//|                                                          RusLine |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "RusLine"
#property link      ""
#property version   "1.60"
#property strict

//--- input parameters
input int      �������=10;
input int      ���������=1;
input int      ���������������=8;
input int      �������=2;
input int      ���=100;
input int      �������=300;
input int      ��������=0;
input int      ����=0;

#define  COUNT_CONST    18

int      oldDay;
int      dayNow;
string   name_obj;
int      index;
double   pivot;

double   rArr[COUNT_CONST];
double   sArr[COUNT_CONST];
double   arrOfLots[COUNT_CONST];
int      countOfLots;
int      isRopen[COUNT_CONST];
int      isSopen[COUNT_CONST];
int      isCanROpen[COUNT_CONST];
int      isCanSOpen[COUNT_CONST];
bool     reinit;


datetime LastDay;



bool NewBar(int tf, datetime &lastbar)
{
   datetime curbar = iTime(_Symbol, tf, 0);
   if(lastbar != curbar)
    {
     lastbar = curbar;
     return (true);
    }
   else return(false);
}

void CalculateDay()
{

   dayNow = DayOfWeek();

   bool NewDay;
   NewDay = NewBar(PERIOD_D1, LastDay);

   //if (oldDay != dayNow || reinit)
   if (NewDay || reinit)
   {
      if (!reinit)
      {
         for(int i = 0; i < COUNT_CONST; i++)
         {
            isCanROpen[i] = 1;
            isCanSOpen[i] = 1;
         }
      }
      if (reinit) reinit = 0;
      
      oldDay = dayNow;
      
      datetime timeNow, timeOfStartDay;
      timeNow = iTime(NULL, 0, 0);
      MqlDateTime str1;
      TimeToStruct(timeNow, str1);
      str1.hour = 0;
      str1.min = 0;
      timeOfStartDay = StructToTime(str1);
            
      double yesterday_close,yesterday_high,yesterday_low;
      //---- Calculate Pivots

      yesterday_high = iHigh(NULL, PERIOD_D1, 1);
      yesterday_low = iLow(NULL, PERIOD_D1, 1);
      yesterday_close = iClose(NULL, PERIOD_D1, 1);

      double R=yesterday_high - yesterday_low;//range
      pivot = (yesterday_high + yesterday_low + yesterday_close)/3;// Standard Pivot
      
      for(int i = 0; i < COUNT_CONST; i++)
      {
         rArr[i] = pivot + (i * ��� * Point) + (�������) * Point;
         sArr[i] = pivot - (i * ��� * Point) - (�������) * Point;
      }
      
      name_obj = "0.000_" + IntegerToString(index, 0, ' ');
      ObjectCreate(name_obj, OBJ_ARROW, 0, timeOfStartDay, pivot+3*Point);      
      ObjectSet(name_obj, OBJPROP_ARROWCODE, 232);
      ObjectSet(name_obj, OBJPROP_COLOR, clrGreen);
      index++;
     
      for(int i = 0; i < COUNT_CONST; i++)
      {
         name_obj = IntegerToString(i, 0, ' ') + "_" + IntegerToString(index, 0, ' ');
         ObjectCreate(name_obj, OBJ_ARROW, 0, timeOfStartDay, rArr[i]+3*Point);      
         ObjectSet(name_obj, OBJPROP_ARROWCODE, 159);
         ObjectSet(name_obj, OBJPROP_COLOR, clrRed);
         index++;
         
         name_obj = "-" + IntegerToString(i, 0, ' ') + "_" + IntegerToString(index, 0, ' ');
         ObjectCreate(name_obj, OBJ_ARROW, 0, timeOfStartDay, sArr[i]+3*Point);      
         ObjectSet(name_obj, OBJPROP_ARROWCODE, 159);
         ObjectSet(name_obj, OBJPROP_COLOR, clrRed);
         index++;
      }
   }
}

bool isReset = false;
bool isChoseR = false;
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
//--- ������� �������� ������
   ResetLastError();
//--- �������� ������� ������� �� ������ ����

   if(id==CHARTEVENT_OBJECT_CLICK)
   {
      if (sparam == "Reset")
      {
         ObjectSetInteger(0,"Reset",OBJPROP_STATE,false);
         isReset = true;
         OnInit();
      }
      if(sparam=="Change")
      {
         if (isChoseR)
         {
            isChoseR = false;
            ButtonTextChange(0, "Change", "S");
            for (int i = 0; i < COUNT_CONST; i++)
            {
               ObjectSetInteger(0,"But"+i,OBJPROP_STATE,isCanSOpen[i]);
               if (isSopen[i] > 0) ButtonTextChange(0, "But"+i, 1);
               else ButtonTextChange(0, "But"+i, 0);
            }
         }
         else
         {
            isChoseR = true;
            ButtonTextChange(0, "Change", "R");
            for (int i = 0; i < COUNT_CONST; i++)
            {
               ObjectSetInteger(0,"But"+i,OBJPROP_STATE,isCanROpen[i]);
               if (isRopen[i] > 0) ButtonTextChange(0, "But"+i, 1);
               else ButtonTextChange(0, "But"+i, 0);
            }
         }
      }
      
      for (int i = 0; i < COUNT_CONST; i++)
      {
         if(sparam==("But"+i))
         {
            if (!isChoseR)
            {
               if (isCanSOpen[i])
               {
                  isCanSOpen[i] = 0;
                  
               }
               else
               {
                  isCanSOpen[i] = 1;
                  
               }
               ObjectSetInteger(0,"But"+i,OBJPROP_STATE,isCanSOpen[i]);
            }
            else
            {
               if (isCanROpen[i])
               {
                  isCanROpen[i] = 0;
                  
               }
               else
               {
                  isCanROpen[i] = 1;
                  
               }
               ObjectSetInteger(0,"But"+i,OBJPROP_STATE,isCanROpen[i]);
            }
         }
      }
      
   }
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   ObjectsDeleteAll();
   name_obj = "";
   index = 0;
   
   int x;
   int y, k = 0;
   x = 20;
   y = 40;
   ButtonCreate(0,"Reset",0,x+1,y-20,62,20,InpCorner,"�����",InpFont,InpFontSize, InpColor,InpBackColor,InpBorderColor,InpState,InpBack,InpSelection,InpHidden,InpZOrder);
   ButtonCreate(0,"Change",0,x+64,y-20,62,20,InpCorner,"��������",InpFont,InpFontSize, InpColor,InpBackColor,InpBorderColor,InpState,InpBack,InpSelection,InpHidden,InpZOrder);
   ButtonTextChange(0, "Change", "S");
   ObjectSetInteger(0,"Reset",OBJPROP_STATE,false);
   for (int i = 1; i <= 3; i++)
   {
      for (int j = 1; j <= 6; j++)
      {
         ButtonCreate(0,"But"+k,0,x*j+j,y,20,20,InpCorner,(string)10,InpFont,InpFontSize, InpColor,InpBackColor,InpBorderColor,InpState,InpBack,InpSelection,InpHidden,InpZOrder);
         k++;
      }
      y = y + 20;
   }

   ObjectSetInteger(0,"Change",OBJPROP_STATE,isChoseR);
   
   if (GlobalVariableGet("ReasonDeinit" + Symbol()) == 1 || isReset) // ��������� ������� � �������
   {
      isReset = false;
      reinit = 0;
      oldDay = DayOfWeek() - 1;
      if (oldDay < 0) oldDay = 5;
      
      LastDay = iTime(Symbol(), PERIOD_D1, 1);
      
      arrOfLots[0] = MarketInfo(Symbol(), MODE_MINLOT);
      for (int i = 1; i < ���������������; i++)
      {
         arrOfLots[i] = arrOfLots[i - 1] * �������;
      }
      for (int i = ���������������; i < COUNT_CONST; i++)
      {
         arrOfLots[i] = arrOfLots[��������������� - 1] * �������;
      }
      
      for (int i = 0; i < COUNT_CONST; i++)
      {
         arrOfLots[i] *= ���������;
      }
      
      countOfLots = 0;
      for(int i = 0; i < COUNT_CONST; i++)
      {
         rArr[i] = 0;
         sArr[i] = 0;
         isRopen[i] = -1;
         isSopen[i] = -1;
         isCanROpen[i] = 1;
         isCanSOpen[i] = 1;
      }

      CalculateDay();
      for(int i = 0; i < COUNT_CONST; i++)
      {
         if (iClose(NULL, PERIOD_M1, 0) > (rArr[i] - ��������*Point))
         {
            isCanROpen[i] = 0;
         }
   
         if (iClose(NULL, PERIOD_M1, 0) < (sArr[i] + ��������*Point))
         {
            isCanSOpen[i] = 0;
         }
      }   
      
      for (int i = 0; i < COUNT_CONST; i++)
      {
         ObjectSetInteger(0,"But"+i,OBJPROP_STATE,isCanSOpen[i]);
         if (isSopen[i] > 0) ButtonTextChange(0, "But"+i, 1);
         else ButtonTextChange(0, "But"+i, 0);
      }
      return(INIT_SUCCEEDED);
   }
   
   oldDay = GlobalVariableGet("oldDay" + Symbol());
   dayNow = GlobalVariableGet("dayNow" + Symbol());
   for (int i = 0; i < COUNT_CONST; i++)
   {
      rArr[i] = GlobalVariableGet("rArr" + i + Symbol());
      sArr[i] = GlobalVariableGet("sArr" + i + Symbol());
      arrOfLots[i] = GlobalVariableGet("arrOfLots" + i + Symbol());
      isRopen[i] = GlobalVariableGet("isRopen" + i + Symbol());
      isSopen[i] = GlobalVariableGet("isSopen" + i + Symbol());
      isCanROpen[i] = GlobalVariableGet("isCanROpen" + i + Symbol());
      isCanSOpen[i] = GlobalVariableGet("isCanSOpen" + i + Symbol());
   }
   for (int i = 0; i < COUNT_CONST; i++)
   {
      ObjectSetInteger(0,"But"+i,OBJPROP_STATE,isCanSOpen[i]);
      if (isSopen[i] > 0) ButtonTextChange(0, "But"+i, 1);
      else ButtonTextChange(0, "But"+i, 0);
   }
   countOfLots = GlobalVariableGet("countOfLots" + Symbol());
   reinit = 1;
   CalculateDay();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---
   ObjectsDeleteAll();
   
   GlobalVariableSet("ReasonDeinit" + Symbol(), reason);
   GlobalVariableSet("countOfLots" + Symbol(), countOfLots);
   GlobalVariableSet("oldDay" + Symbol(), oldDay);
   GlobalVariableSet("dayNow" + Symbol(), dayNow);
   for (int i = 0; i < COUNT_CONST; i++)
   {
      GlobalVariableSet("rArr" + i + Symbol(), rArr[i]);
      GlobalVariableSet("sArr" + i + Symbol(), sArr[i]);
      GlobalVariableSet("arrOfLots" + i + Symbol(), arrOfLots[i]);
      GlobalVariableSet("isRopen" + i + Symbol(), isRopen[i]);
      GlobalVariableSet("isSopen" + i + Symbol(), isSopen[i]);
      GlobalVariableSet("isCanROpen" + i + Symbol(), isCanROpen[i]);
      GlobalVariableSet("isCanSOpen" + i + Symbol(), isCanSOpen[i]);
   }
}

//+------------------------------------------------------------------+
//| ������� �������� �������                                         |
//+------------------------------------------------------------------+
int OpenOrder(int cmd)
{
//---
   int ticket;
   if (cmd == OP_SELL)
   {
      double bid = MarketInfo(Symbol(),MODE_BID); // ������ �������� Bid
      double bid1, bid2;
      if (���� == 0) bid1 = 0;
      else bid1 = MarketInfo(Symbol(),MODE_BID); // ������ �������� Ask
      if (������� == 0) bid2 = 0;
      else bid2 = MarketInfo(Symbol(),MODE_BID); // ������ �������� Ask
      //ticket = OrderSend(Symbol(), OP_SELL, arrOfLots[countOfLots], bid, 5, NormalizeDouble(bid1+����*Point,Digits), NormalizeDouble(bid2-�������*Point,Digits), NULL, 0, 0, Green); 
      ticket = OrderSend(Symbol(), OP_SELL, arrOfLots[countOfLots], bid, 5, 0, NormalizeDouble(bid2-�������*Point,Digits), NULL, 0, 0, Green); 
   }
   else
   {
      double ask = MarketInfo(Symbol(),MODE_ASK); // ������ �������� Ask
      
      double ask1, ask2;
      if (���� == 0) ask1 = 0;
      else ask1 = MarketInfo(Symbol(),MODE_ASK); // ������ �������� Ask
      if (������� == 0) ask2 = 0;
      else ask2 = MarketInfo(Symbol(),MODE_ASK); // ������ �������� Ask
      //ticket = OrderSend(Symbol(), OP_BUY, arrOfLots[countOfLots], ask, 5, NormalizeDouble(ask1-����*Point,Digits), NormalizeDouble(ask2+�������*Point,Digits), NULL, 0, 0, Red);
      ticket = OrderSend(Symbol(), OP_BUY, arrOfLots[countOfLots], ask, 5, 0, NormalizeDouble(ask2+�������*Point,Digits), NULL, 0, 0, Red);
   }
   
   if(ticket > 0)
   {
      //if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
      //   Print("Order opened : ", " "OrderOpenPrice());
      IncLots();
      return ticket;
   }
   else
   {
      if (ticket == 0) return -1;
      int err;
      err = GetLastError();
      //Alert ("������ ��������: ", err);
      Print("Error opening order : ", err, "; ���: ",arrOfLots[countOfLots]);
   }
   return -1;
}

void IncLots()
{
   countOfLots++;
   if (countOfLots >= COUNT_CONST) countOfLots = COUNT_CONST - 1;
}

//int CloseAllOrders(int pos){
//   for(int i = 0; i < COUNT_CONST; i++)
//   {
//      if ( i != pos)
//      {
//         if (isSopen[i] != -1)
//         {
//            if(OrderSelect(isSopen[i], SELECT_BY_TICKET, MODE_TRADES))
//            {
//               if (OrderClose(isSopen[i], OrderLots(), Bid, 5, Red))
//               {
//                  isSopen[i] = -1;
//                  //return 1;
//               }
//               else
//               {
//                  int err;
//                  err = GetLastError();
//                  if (err == ERR_INVALID_TICKET) isSopen[i] = -1;
//                  //else Alert ("������ ��������: ", err);
//                  Print("Error closing order : ",err);
//                  return 0;
//               }
//            }
//         }
//      
//      
//         if (isRopen[i] != -1)
//         {
//            if(OrderSelect(isRopen[i], SELECT_BY_TICKET, MODE_TRADES))
//            {
//               if (OrderClose(isRopen[i], OrderLots(), Bid, 5, Red))
//               {
//                  isRopen[i] = -1;
//                  //return 1;
//               }
//               else
//               {
//                  int err;
//                  err = GetLastError();
//                  if (err == ERR_INVALID_TICKET) isRopen[i] = -1;
//                  //else Alert ("������ ��������: ", err);
//                  Print("Error closing order : ",err);
//                  return 0;
//               }
//            }
//         }
//      }
//   }
//   return 1;
//}

bool CloseOrders(int dir)
{
  // ������� �������� �������
        int i, total = OrdersTotal();   if (total<=0) return(true);
        int ticket[1000], nt=0;
      int Slip = 1000;
        nt=0;
        for (i=0; i<total; i++) 
        {       
                if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) return(false); 
                if (OrderType()==dir||dir<0 && (OrderSymbol()==Symbol()))
                { ticket[nt]=OrderTicket(); nt++; }
        }
        for (i=0; i<nt; i++)
        {       
                OrderSelect(ticket[i], SELECT_BY_TICKET);       
                if (OrderType()==OP_BUY) if (!OrderClose(ticket[i], OrderLots(), NormalizeDouble(OrderClosePrice(), Digits), Slip)) return(false);
                if (OrderType()==OP_SELL) if (!OrderClose(ticket[i], OrderLots(), NormalizeDouble(OrderClosePrice(), Digits), Slip)) return(false);
                if (OrderType()==OP_BUYLIMIT || OrderType()==OP_SELLLIMIT || OrderType()==OP_BUYSTOP || OrderType()==OP_SELLSTOP)
                        if (!OrderDelete(ticket[i])) return(false);
        }
        return(true);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---
   CalculateDay();
   for (int i = 0; i < COUNT_CONST; i++)
   {
      if (!isChoseR)
      {
         ObjectSetInteger(0,"But"+i,OBJPROP_STATE,isCanSOpen[i]);
         if (isSopen[i] > 0) ButtonTextChange(0, "But"+i, 1);
         else ButtonTextChange(0, "But"+i, 0);      
      }
      else
      {
         ObjectSetInteger(0,"But"+i,OBJPROP_STATE,isCanROpen[i]);
         if (isRopen[i] > 0) ButtonTextChange(0, "But"+i, 1);
         else ButtonTextChange(0, "But"+i, 0);       
      }
   }
      for(int i = 0; i < COUNT_CONST; i++)
      {
         if (MarketInfo(Symbol(), MODE_ASK) >= (rArr[i] - ��������*Point) && isRopen[i] == -1 && isCanROpen[i])
         {
            isRopen[i] = OpenOrder(OP_SELL);
            if (isRopen[i] != -1) isCanROpen[i] = 0;
         }
         
         if (MarketInfo(Symbol(), MODE_BID) <= (sArr[i] + ��������*Point) && isSopen[i] == -1 && isCanSOpen[i])
         {
            isSopen[i] = OpenOrder(OP_BUY);
            if (isSopen[i] != -1) isCanSOpen[i] = 0;
         }
         
         if(OrderSelect(isRopen[i], SELECT_BY_TICKET, MODE_TRADES) == true && isRopen[i] != -1)      
         {
            datetime ctm = OrderCloseTime();
            if (ctm > 0)
            {
               while(!CloseOrders(-1));
               countOfLots = 0;
               for(int cnt = 0; cnt < COUNT_CONST; cnt++)
               {
                  isRopen[cnt] = -1;
                  isSopen[cnt] = -1;
               }
            }
         }
         
         if(OrderSelect(isSopen[i], SELECT_BY_TICKET, MODE_TRADES) == true && isSopen[i] != -1)      
         {
            datetime ctm = OrderCloseTime();
            if (ctm > 0)
            {
               while(!CloseOrders(-1));
               countOfLots = 0;
               for(int cnt = 0; cnt < COUNT_CONST; cnt++)
               {
                  isRopen[cnt] = -1;
                  isSopen[cnt] = -1;
               }
            }
         }
      }
   //}
   //else Print("SymbolInfoTick() failed, error = ",GetLastError());


}
//+------------------------------------------------------------------+

string           InpName="Button";            // ��� ������
ENUM_BASE_CORNER InpCorner=CORNER_LEFT_UPPER; // ���� ������� ��� ��������
string           InpFont="Arial";             // �����
int              InpFontSize=10;              // ������ ������
color            InpColor=clrBlack;           // ���� ������
color            InpBackColor=C'236,233,216'; // ���� ����
color            InpBorderColor=clrNONE;      // ���� �������
bool             InpState=false;              // ������/������
bool             InpBack=false;               // ������ �� ������ �����
bool             InpSelection=false;          // �������� ��� �����������
bool             InpHidden=true;              // ����� � ������ ��������
long             InpZOrder=0;                 // ��������� �� ������� �����
//+------------------------------------------------------------------+
//| ������� ������                                                   |
//+------------------------------------------------------------------+
bool ButtonCreate(const long              chart_ID=0,               // ID �������
                  const string            name="Button",            // ��� ������
                  const int               sub_window=0,             // ����� �������
                  const int               x=0,                      // ���������� �� ��� X
                  const int               y=0,                      // ���������� �� ��� Y
                  const int               width=50,                 // ������ ������
                  const int               height=18,                // ������ ������
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // ���� ������� ��� ��������
                  const string            text="Button",            // �����
                  const string            font="Arial",             // �����
                  const int               font_size=10,             // ������ ������
                  const color             clr=clrBlack,             // ���� ������
                  const color             back_clr=C'236,233,216',  // ���� ����
                  const color             border_clr=clrNONE,       // ���� �������
                  const bool              state=false,              // ������/������
                  const bool              back=false,               // �� ������ �����
                  const bool              selection=false,          // �������� ��� �����������
                  const bool              hidden=true,              // ����� � ������ ��������
                  const long              z_order=0)                // ��������� �� ������� �����
  {
//--- ������� �������� ������
   ResetLastError();
//--- �������� ������
   if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": �� ������� ������� ������! ��� ������ = ",GetLastError());
      return(false);
     }
//--- ��������� ���������� ������
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- ��������� ������ ������
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- ��������� ���� �������, ������������ �������� ����� ������������ ���������� �����
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- ��������� �����
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- ��������� ����� ������
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- ��������� ������ ������
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- ��������� ���� ������
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- ��������� ���� ����
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- ��������� ���� �������
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
//--- ��������� �� �������� (false) ��� ������ (true) �����
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- ��������� ������ � �������� ���������
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
//--- ������� (true) ��� �������� (false) ����� ����������� ������ �����
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- ������ (true) ��� ��������� (false) ��� ������������ ������� � ������ ��������
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- ��������� ��������� �� ��������� ������� ������� ���� �� �������
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);

ObjectSetInteger(chart_ID,name,OBJPROP_BACK,0);
   return(true);
  }
//+------------------------------------------------------------------+
//| ���������� ������                                                |
//+------------------------------------------------------------------+
bool ButtonMove(const long   chart_ID=0,    // ID �������
                const string name="Button", // ��� ������
                const int    x=0,           // ���������� �� ��� X
                const int    y=0)           // ���������� �� ��� Y
  {
//--- ������� �������� ������
   ResetLastError();
//--- ���������� ������
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x))
     {
      Print(__FUNCTION__,
            ": �� ������� ����������� X-���������� ������! ��� ������ = ",GetLastError());
      return(false);
     }
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y))
     {
      Print(__FUNCTION__,
            ": �� ������� ����������� Y-���������� ������! ��� ������ = ",GetLastError());
      return(false);
     }
//--- �������� ����������
   return(true);
  }
//+------------------------------------------------------------------+
//| �������� ������ ������                                           |
//+------------------------------------------------------------------+
bool ButtonChangeSize(const long   chart_ID=0,    // ID �������
                      const string name="Button", // ��� ������
                      const int    width=50,      // ������ ������
                      const int    height=18)     // ������ ������
  {
//--- ������� �������� ������
   ResetLastError();
//--- ������� ������� ������
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width))
     {
      Print(__FUNCTION__,
            ": �� ������� �������� ������ ������! ��� ������ = ",GetLastError());
      return(false);
     }
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height))
     {
      Print(__FUNCTION__,
            ": �� ������� �������� ������ ������! ��� ������ = ",GetLastError());
      return(false);
     }
//--- �������� ����������
   return(true);
  }
//+------------------------------------------------------------------+
//| �������� ����� ������                                            |
//+------------------------------------------------------------------+
bool ButtonTextChange(const long   chart_ID=0,    // ID �������
                      const string name="Button", // ��� ������
                      const string text="Text")   // �����
  {
//--- ������� �������� ������
   ResetLastError();
//--- ������� ����� �������
   if(!ObjectSetString(chart_ID,name,OBJPROP_TEXT,text))
     {
      Print(__FUNCTION__,
            ": �� ������� �������� �����! ��� ������ = ",GetLastError());
      return(false);
     }
//--- �������� ����������
   return(true);
  }
//+------------------------------------------------------------------+
//| ������� ������                                                   |
//+------------------------------------------------------------------+
bool ButtonDelete(const long   chart_ID=0,    // ID �������
                  const string name="Button") // ��� ������
  {
//--- ������� �������� ������
   ResetLastError();
//--- ������ ������
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": �� ������� ������� ������! ��� ������ = ",GetLastError());
      return(false);
     }
//--- �������� ����������
   return(true);
  }