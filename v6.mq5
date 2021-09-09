//+------------------------------------------------------------------+
//|                                                           v6.mq5 |
//|                                                Bokang Ntshihlele |
//|                                                       ////////// |
//+------------------------------------------------------------------+
#property copyright "Bokang Ntshihlele"
#property link      "//////////"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
//--- available signals
#include <Expert\Signal\ATR.mqh>
#include <Expert\Signal\adx.mqh>
#include <Expert\Signal\SignalVol.mqh>
#include <Expert\Signal\SignalMACD.mqh>
#include <Expert\Signal\SignalStoch.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingFixedPips.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedLot.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Expert_Title                  ="v6";        // Document name
ulong                    Expert_MagicNumber            =27485;       //
bool                     Expert_EveryTick              =false;       //
//--- inputs for main signal
input int                Signal_ThresholdOpen          =10;          // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose         =10;          // Signal threshold value to close [0...100]
input double             Signal_PriceLevel             =0.0;         // Price level to execute a deal
input double             Signal_StopLevel              =50.0;        // Stop Loss level (in points)
input double             Signal_TakeLevel              =50.0;        // Take Profit level (in points)
input int                Signal_Expiration             =4;           // Expiration of pending orders (in bars)
input int                Signal_ATR_PeriodATR          =8;           // Average True Range(8,...) Period of calculation
input ENUM_APPLIED_PRICE Signal_ATR_Applied            =PRICE_CLOSE; // Average True Range(8,...) Prices series
input double             Signal_ATR_Weight             =1.0;         // Average True Range(8,...) Weight [0...1.0]
input int                Signal_ADX_PeriodADX          =8;           // Average Directional Movement Period of calculation
input ENUM_APPLIED_PRICE Signal_ADX_Applied            =PRICE_CLOSE; // Average Directional Movement Prices series
input double             Signal_ADX_Weight             =1.0;         // Average Directional Movement Weight [0...1.0]
input int                Signal_Vols_PeriodBears       =13;          // Volumes(13) Period of calculation
input double             Signal_Vols_Weight            =1.0;         // Volumes(13) Weight [0...1.0]
input int                Signal_MACD_PeriodFast        =12;          // MACD(12,24,9,PRICE_CLOSE) Period of fast EMA
input int                Signal_MACD_PeriodSlow        =24;          // MACD(12,24,9,PRICE_CLOSE) Period of slow EMA
input int                Signal_MACD_PeriodSignal      =9;           // MACD(12,24,9,PRICE_CLOSE) Period of averaging of difference
input ENUM_APPLIED_PRICE Signal_MACD_Applied           =PRICE_CLOSE; // MACD(12,24,9,PRICE_CLOSE) Prices series
input double             Signal_MACD_Weight            =1.0;         // MACD(12,24,9,PRICE_CLOSE) Weight [0...1.0]
input int                Signal_Stoch_PeriodK          =8;           // Stochastic(8,3,3,...) K-period
input int                Signal_Stoch_PeriodD          =3;           // Stochastic(8,3,3,...) D-period
input int                Signal_Stoch_PeriodSlow       =3;           // Stochastic(8,3,3,...) Period of slowing
input ENUM_STO_PRICE     Signal_Stoch_Applied          =STO_LOWHIGH; // Stochastic(8,3,3,...) Prices to apply to
input double             Signal_Stoch_Weight           =1.0;         // Stochastic(8,3,3,...) Weight [0...1.0]
//--- inputs for trailing
input int                Trailing_FixedPips_StopLevel  =30;          // Stop Loss trailing level (in points)
input int                Trailing_FixedPips_ProfitLevel=50;          // Take Profit trailing level (in points)
//--- inputs for money
input double             Money_FixLot_Percent          =5.0;         // Percent
input double             Money_FixLot_Lots             =0.01;        // Fixed volume
//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+
CExpert ExtExpert;
//+------------------------------------------------------------------+
//| Initialization function of the expert                            |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Initializing expert
   if(!ExtExpert.Init(Symbol(),Period(),Expert_EveryTick,Expert_MagicNumber))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing expert");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Creating signal
   CExpertSignal *signal=new CExpertSignal;
   if(signal==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating signal");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//---
   ExtExpert.InitSignal(signal);
   signal.ThresholdOpen(Signal_ThresholdOpen);
   signal.ThresholdClose(Signal_ThresholdClose);
   signal.PriceLevel(Signal_PriceLevel);
   signal.StopLevel(Signal_StopLevel);
   signal.TakeLevel(Signal_TakeLevel);
   signal.Expiration(Signal_Expiration);
//--- Creating filter CSignalATR
   CSignalATR *filter0=new CSignalATR;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.PeriodATR(Signal_ATR_PeriodATR);
   filter0.Applied(Signal_ATR_Applied);
   filter0.Weight(Signal_ATR_Weight);
//--- Creating filter CSignalADX
   CSignalADX *filter1=new CSignalADX;
   if(filter1==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter1");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter1);
//--- Set filter parameters
   filter1.PeriodADX(Signal_ADX_PeriodADX);
   filter1.Applied(Signal_ADX_Applied);
   filter1.Weight(Signal_ADX_Weight);
//--- Creating filter CSignalBearsPower
   CSignalBearsPower *filter2=new CSignalBearsPower;
   if(filter2==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter2");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter2);
//--- Set filter parameters
   filter2.PeriodBears(Signal_Vols_PeriodBears);
   filter2.Weight(Signal_Vols_Weight);
//--- Creating filter CSignalMACD
   CSignalMACD *filter3=new CSignalMACD;
   if(filter3==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter3");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter3);
//--- Set filter parameters
   filter3.PeriodFast(Signal_MACD_PeriodFast);
   filter3.PeriodSlow(Signal_MACD_PeriodSlow);
   filter3.PeriodSignal(Signal_MACD_PeriodSignal);
   filter3.Applied(Signal_MACD_Applied);
   filter3.Weight(Signal_MACD_Weight);
//--- Creating filter CSignalStoch
   CSignalStoch *filter4=new CSignalStoch;
   if(filter4==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter4");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter4);
//--- Set filter parameters
   filter4.PeriodK(Signal_Stoch_PeriodK);
   filter4.PeriodD(Signal_Stoch_PeriodD);
   filter4.PeriodSlow(Signal_Stoch_PeriodSlow);
   filter4.Applied(Signal_Stoch_Applied);
   filter4.Weight(Signal_Stoch_Weight);
//--- Creation of trailing object
   CTrailingFixedPips *trailing=new CTrailingFixedPips;
   if(trailing==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add trailing to expert (will be deleted automatically))
   if(!ExtExpert.InitTrailing(trailing))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set trailing parameters
   trailing.StopLevel(Trailing_FixedPips_StopLevel);
   trailing.ProfitLevel(Trailing_FixedPips_ProfitLevel);
//--- Creation of money object
   CMoneyFixedLot *money=new CMoneyFixedLot;
   if(money==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add money to expert (will be deleted automatically))
   if(!ExtExpert.InitMoney(money))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set money parameters
   money.Percent(Money_FixLot_Percent);
   money.Lots(Money_FixLot_Lots);
//--- Check all trading objects parameters
   if(!ExtExpert.ValidationSettings())
     {
      //--- failed
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Tuning of all necessary indicators
   if(!ExtExpert.InitIndicators())
     {
      //--- failed
      printf(__FUNCTION__+": error initializing indicators");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- ok
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ExtExpert.Deinit();
  }
//+------------------------------------------------------------------+
//| "Tick" event handler function                                    |
//+------------------------------------------------------------------+
void OnTick()
  {
   ExtExpert.OnTick();
  }
//+------------------------------------------------------------------+
//| "Trade" event handler function                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
   ExtExpert.OnTrade();
  }
//+------------------------------------------------------------------+
//| "Timer" event handler function                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ExtExpert.OnTimer();
  }
//+------------------------------------------------------------------+
