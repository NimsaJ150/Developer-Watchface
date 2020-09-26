using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;
using Toybox.Timer as Timer;
using Toybox.Time.Gregorian as Date;
using Toybox.ActivityMonitor as Mon;

class testView extends WatchUi.WatchFace {
	
	// defining defaults
	var default_font = WatchUi.loadResource(Rez.Fonts.font_ubuntu);
	var default_font_hb = WatchUi.loadResource(Rez.Fonts.font_ubuntu_hb);
	var def_start_Y = 45;
	var def_increment_Y = 20.5;
	var def_start_X = 20;
	var def_increment_X = 60;
	var text_color = 0xFFFFFF;
	
    //in right order
	var list = ["DateText","TimeText", "BatteryText", "StepText",  "MessageText"];
	
	// timer
	var timer1 = new Timer.Timer();


    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
  
	
	}
	
    function initialize() {
        WatchFace.initialize();
        
    
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    	
    }

    // Update the view
    function onUpdate(dc) {
        setHead();
        setClockDisplay();
		setDateDisplay();
		setBatteryDisplay();
		setStepCountDisplay();
		setNotificationCountDisplay();
		setDisplayText();
		setBottom();
		setCursor();
		
		
		
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    	
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    
		timer1.start(test(), 500, false);
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    timer1.stop();
    }
    
    private function setDisplayText() {
    	// display the descriptive texts contained in the list
    	for (var i=0; i<list.size(); i++){
    		var view = View.findDrawableById(list[i]);
			view.setFont(default_font);
			view.setColor(text_color);
			view.setLocation(def_start_X, def_start_Y + (i+1)*def_increment_Y);
		}
    
    }
    
    private function setHead() {
    	// display the head command line        
		var view = View.findDrawableById("Head");
		view.setFont(default_font_hb);
		view.setColor(text_color);
		view.setLocation(def_start_X, def_start_Y + 0*def_increment_Y - 3);  
    }
    
    private function setBottom() {     
    	// display the bottom command line   
		var view = View.findDrawableById("Bottom");
		view.setFont(default_font_hb);
		view.setColor(text_color);
		view.setLocation(def_start_X, def_start_Y + (list.size()+1)*def_increment_Y + 3);  
    }
    
    private function setCursor() {
    	// display the head command line        
		var view = View.findDrawableById("Cursor");
		
		var clockTime = System.getClockTime().sec;
		
		view.setText("");
		
		view.setLocation(170, def_start_Y + (list.size()+1)*def_increment_Y);
		
    }
    
    private function test() {
    	System.println("T");
    }
    
    private function setClockDisplay() {
    	// Get the current time and format it correctly
        var timeFormat = "$1$:$2$:$3$ $4$ $5$";
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        
        // get AM or PM right
        var meridies ="";
        if (hours < 12){
        	meridies = "AM";
        } else{
        	meridies = "PM";
        }
        
        // get hour format right
        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        }
        
        // Get the european time Zone
        var utcOffset = clockTime.timeZoneOffset/3600;
        var timeZone = "";
        if (utcOffset == 1){
        	timeZone = "CET";
        }
        else if (utcOffset == 2){
        	timeZone = "CEST";
        }
        
        // format the time
        var timeString = Lang.format(timeFormat, [hours, clockTime.min.format("%02d"), clockTime.sec.format("%02d"), meridies, timeZone]);
		
		
        // Update the view
        var view = View.findDrawableById("TimeLabel");
        view.setFont(default_font);
        view.setLocation(def_start_X + def_increment_X, def_start_Y + (list.indexOf("TimeText")+1)*def_increment_Y);
        view.setColor(Application.getApp().getProperty("YellowColor"));
        view.setText(timeString);
    }
    
    private function setDateDisplay() { 
    	// format and display the date       
    	var now = Time.now();
		var date = Date.info(now, Time.FORMAT_LONG);
		var dateString = Lang.format("$1$ $2$ $3$ $4$", [date.day_of_week, date.month, date.day, date.year]);
		var dateDisplay = View.findDrawableById("DateDisplay");
		dateDisplay.setFont(default_font);
		dateDisplay.setLocation(def_start_X + def_increment_X, def_start_Y + (list.indexOf("DateText")+1)*def_increment_Y);
        dateDisplay.setColor(Application.getApp().getProperty("PinkColor"));   
		dateDisplay.setText(dateString);	    	
    }
    
    private function setBatteryDisplay() {
    	// format and display the battery status
    	var battery = System.getSystemStats().battery;
    	
    	// create status view
    	var battBar = "[";
    	var count = battery;
    	count.format("%i");
    	
    	for (var i=0; i<100; i+=10){
    		if (i<=count-10){
    			battBar += "#";
    		}
    		else{
    			battBar += ".";
    		}
    	}
    	battBar += "] ";
    	
    	// Update the view
		var batteryDisplay = View.findDrawableById("BatteryDisplay"); 
		batteryDisplay.setFont(default_font);
        batteryDisplay.setColor(Application.getApp().getProperty("CyanColor"));
		batteryDisplay.setLocation(def_start_X + def_increment_X, def_start_Y + (list.indexOf("BatteryText")+1)*def_increment_Y);     
		batteryDisplay.setText(battBar + battery.format("%d")+" %");	
    }
    
    private function setStepCountDisplay() {
    	// format and display the steps and step goal
    	var stepCount = Mon.getInfo().steps.toString();	
    	var stepGoal = Mon.getInfo().stepGoal.toString();	
		var stepCountDisplay = View.findDrawableById("StepCountDisplay");
		stepCountDisplay.setFont(default_font);
        stepCountDisplay.setColor(Application.getApp().getProperty("OrangeColor"));
		stepCountDisplay.setLocation(def_start_X + def_increment_X, def_start_Y + (list.indexOf("StepText")+1)*def_increment_Y);   
		stepCountDisplay.setText(stepCount + "/" + stepGoal + " steps");		
    }
    
    private function setNotificationCountDisplay() {
    	// format and display the notification number
    	var notificationAmount = System.getDeviceSettings().notificationCount;
		
		var formattedNotificationAmount = "";
	
		if(notificationAmount > 10)	{
			formattedNotificationAmount = "10+";
		}
		else {
			formattedNotificationAmount = notificationAmount.format("%d");
		}
		
		// Update the view
		var notificationCountDisplay = View.findDrawableById("MessageCountDisplay");
        notificationCountDisplay.setColor(Application.getApp().getProperty("GreenColor"));		
		notificationCountDisplay.setFont(default_font); 
		notificationCountDisplay.setLocation(def_start_X + def_increment_X, def_start_Y + (list.indexOf("MessageText")+1)*def_increment_Y);   
		notificationCountDisplay.setText(formattedNotificationAmount + " messages");
    }
}