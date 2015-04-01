//+------------------------------------------------------------------+
//|                                                     TestV2.0.mq4 |
//|                                                          RusLine |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "RusLine"
#property link      ""
#property version   "2.20"
#property strict

//--- input parameters
input int      �������=10;
input int      ���������=1;
input int      ���������������=8;
input int      �������=2;
input int      ��������=0;
input int      ����=0;

#define  COUNT_CONST    18

int      oldDay;
int      isCalc;
int      isOpenOrder;
string   name;
int      index;
double   p;

double   fibConsts[COUNT_CONST]={0.236, 0.382, 0.500, 0.618, 0.764, 1.000, 1.236, 1.382, 1.500, 1.618, 1.764, 2.000, 2.236, 2.382, 2.500, 2.618, 2.764, 3.000};
double   rArr[COUNT_CONST];
double   sArr[COUNT_CONST];
//double   arrOfLots[COUNT_CONST]={0.01, 0.03, 0.09, 0.27, 0.81, 2.43, 2.43, 2.43, 2.43, 2.43, 2.43, 2.43, 2.43, 2.43, 2.43, 2.43, 2.43, 2.43};
double   arrOfLots[COUNT_CONST]={0.01, 0.02, 0.04, 0.08, 0.16, 0.32, 0.64, 1.28, 1.28, 1.28, 1.28, 1.28, 1.28, 1.28, 1.28, 1.28, 1.28, 1.28};
int      countOfLots;
int      isRopen[COUNT_CONST];
int      isSopen[COUNT_CONST];
int      isCanROpen[COUNT_CONST];
int      isCanSOpen[COUNT_CONST];




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
//--- �������� ����������
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


void CalculateDay()
{
   int dayNow;
   dayNow = DayOfWeek();

   if (oldDay != dayNow)
   {
      for(int i = 0; i < COUNT_CONST; i++)
      {
         isCanROpen[i] = 1;
         isCanSOpen[i] = 1;
      }
      
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
      p = (yesterday_high + yesterday_low + yesterday_close)/3;// Standard Pivot
      for(int i = 0; i < COUNT_CONST; i++)
      {
         rArr[i] = p + (R * fibConsts[i]);
         sArr[i] = p - (R * fibConsts[i]);
      }
      
      name = "0.000_" + IntegerToString(index, 0, ' ');
      ObjectCreate(name, OBJ_ARROW, 0, timeOfStartDay, p+3*Point);      
      ObjectSet(name, OBJPROP_ARROWCODE, 232);
      ObjectSet(name, OBJPROP_COLOR, clrGreen);
      index++;
     
      for(int i = 0; i < COUNT_CONST; i++)
      {
         name = DoubleToString(fibConsts[i], 3) + "_" + IntegerToString(index, 0, ' ');
         ObjectCreate(name, OBJ_ARROW, 0, timeOfStartDay, rArr[i]+3*Point);      
         ObjectSet(name, OBJPROP_ARROWCODE, 159);
         ObjectSet(name, OBJPROP_COLOR, clrRed);
         index++;
         
         name = "-" + DoubleToString(fibConsts[i], 3) + "_" + IntegerToString(index, 0, ' ');
         ObjectCreate(name, OBJ_ARROW, 0, timeOfStartDay, sArr[i]+3*Point);      
         ObjectSet(name, OBJPROP_ARROWCODE, 159);
         ObjectSet(name, OBJPROP_COLOR, clrRed);
         index++;
      }
   }
}


bool button_0 = false;
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
//--- ������� �������� ������
   ResetLastError();
//--- �������� ������� ������� �� ������ ����

   if(id==CHARTEVENT_OBJECT_CLICK)
   {
      //--------------������ "�����"----------------------------------    
      if(sparam==InpName && !button_0)
      {
         ObjectSetInteger(0,InpName,OBJPROP_STATE,false);
         button_0=true;
         
      }else
      
      if(sparam==InpName && button_0)
      {
      ObjectSetInteger(0,InpName,OBJPROP_STATE,false);
         button_0=false;
         
      }
   }
   
      if (button_0 == true)
   {
   Comment("YES");
   }
   else
   {
    Comment("No");
    }
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
//--- �������� ������
   int x;
   int y, k = 0;
   x = 20;
   y = 40;
   
   ButtonCreate(0,"Hide",0,x+1,y-20,62,20,InpCorner,"��������",InpFont,InpFontSize, InpColor,InpBackColor,InpBorderColor,InpState,InpBack,InpSelection,InpHidden,InpZOrder);
   ButtonCreate(0,"Change",0,x+64,y-20,62,20,InpCorner,"��������",InpFont,InpFontSize, InpColor,InpBackColor,InpBorderColor,InpState,InpBack,InpSelection,InpHidden,InpZOrder);

   for (int i = 1; i <= 3; i++)
   {
      for (int j = 1; j <= 6; j++)
      {
         ButtonCreate(0,"But"+k,0,x*j+j,y,20,20,InpCorner,(string)10,InpFont,InpFontSize, InpColor,InpBackColor,InpBorderColor,InpState,InpBack,InpSelection,InpHidden,InpZOrder);
         k++;
      }
      y = y + 20;
   }
    
//--- ���������� ������
   ChartRedraw();

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
   name = "";
   index = 0;
   isOpenOrder = 0;
   oldDay = DayOfWeek() - 1;
   if (oldDay < 0) oldDay = 5;
   
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
  }

//+------------------------------------------------------------------+
//| ������� �������� �������                                 |
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

int CloseAllOrders(int pos){
   for(int i = 0; i < COUNT_CONST; i++)
   {
      if ( i != pos)
      {
         if (isSopen[i] != -1)
         {
            if(OrderSelect(isSopen[i], SELECT_BY_TICKET, MODE_TRADES))
            {
               if (OrderClose(isSopen[i], OrderLots(), Bid, 5, Red))
               {
                  isSopen[i] = -1;
                  //return 1;
               }
               else
               {
                  int err;
                  err = GetLastError();
                  if (err == ERR_INVALID_TICKET) isSopen[i] = -1;
                  //else Alert ("������ ��������: ", err);
                  Print("Error closing order : ",err);
                  return 0;
               }
            }
         }
      
      
         if (isRopen[i] != -1)
         {
            if(OrderSelect(isRopen[i], SELECT_BY_TICKET, MODE_TRADES))
            {
               if (OrderClose(isRopen[i], OrderLots(), Bid, 5, Red))
               {
                  isRopen[i] = -1;
                  //return 1;
               }
               else
               {
                  int err;
                  err = GetLastError();
                  if (err == ERR_INVALID_TICKET) isRopen[i] = -1;
                  //else Alert ("������ ��������: ", err);
                  Print("Error closing order : ",err);
                  return 0;
               }
            }
         }
      }
   }
   return 1;
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---

   /*Comment("[1]:", isCanROpen[0],"|", isCanSOpen[0], "  [2]:", isCanROpen[1],"|", isCanSOpen[1], "  [3]:", isCanROpen[2],"|", isCanSOpen[2], "\n",
   "[4]:", isCanROpen[3],"|", isCanSOpen[3], "  [5]:", isCanROpen[4],"|", isCanSOpen[4], "  [6]:", isCanROpen[5],"|", isCanSOpen[5], "\n",
   "[7]:", isCanROpen[6],"|", isCanSOpen[6], "  [8]:", isCanROpen[7],"|", isCanSOpen[7], "  [9]:", isCanROpen[8],"|", isCanSOpen[8], "\n");
   */
   //"[10]:", isCanROpen[9],"|", isCanSOpen[9], " [11]:", isCanROpen[10],"|", isCanSOpen[10], " [12]:", isCanROpen[11],"|", isCanSOpen[11], "\n",
   //"[13]:", isCanROpen[12],"|", isCanSOpen[12], " [14]:", isCanROpen[13],"|", isCanSOpen[13], " [15]:", isCanROpen[14],"|", isCanSOpen[14], "\n",
   //"[16]:", isCanROpen[15],"|", isCanSOpen[15], " [17]:", isCanROpen[16],"|", isCanSOpen[16], " [18]:", isCanROpen[17],"|", isCanSOpen[17]);
   CalculateDay();
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
               if (CloseAllOrders(i))
               {
                  countOfLots = 0;
                  isRopen[i] = -1;
               }
            }
         }
         
         if(OrderSelect(isSopen[i], SELECT_BY_TICKET, MODE_TRADES) == true && isSopen[i] != -1)      
         {
            datetime ctm = OrderCloseTime();
            if (ctm > 0)
            {
               
               if (CloseAllOrders(i))
               {
                  countOfLots = 0;
                  isSopen[i] = -1;
               }
            }
         }
      }
   //}
   //else Print("SymbolInfoTick() failed, error = ",GetLastError());


}
//+------------------------------------------------------------------+
