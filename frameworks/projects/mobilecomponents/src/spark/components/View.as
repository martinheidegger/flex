////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components
{
import flash.events.StageOrientationEvent;

import mx.core.FlexGlobals;
import mx.core.IDataRenderer;
import mx.core.IVisualElement;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.PropertyChangeEvent;
import mx.managers.SystemManager;

import spark.core.ContainerDestructionPolicy;
import spark.events.ViewNavigatorEvent;
import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the back key is pressed when a view exists inside
 *  a mobile application.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 * 
 *  @eventType mx.events.FlexEvent.BACK_KEY_PRESSED
 * 
 */
[Event(name="backKeyPressed", type="mx.events.FlexEvent")]

/**
 *  Dispatched when the <code>data</code> property changes.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 * 
 *  @eventType mx.events.FlexEvent.DATA_CHANGE
 * 
 */
[Event(name="dataChange", type="mx.events.FlexEvent")]

/**
 *  Dispatched when the menu key is pressed when a view exists inside
 *  a mobile application.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 * 
 *  @eventType mx.events.FlexEvent.MENU_KEY_PRESSED
 * 
 */
[Event(name="menuKeyPressed", type="mx.events.FlexEvent")]

/**
 *  Dispatched when the current view has been activated.
 * 
 *  @eventType mx.events.ViewNavigatorEvent.VIEW_ACTIVATE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="viewActivate", type="spark.events.ViewNavigatorEvent")]

/**
 *  Dispatched when the current view has been deactivated.
 * 
 *  @eventType mx.events.ViewNavigatorEvent.VIEW_DEACTIVATE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="viewDeactivate", type="spark.events.ViewNavigatorEvent")]

/**
 *  Dispatched when the screen is about to be removed in response
 *  to a screen change.  Calling <code>preventDefault()</code> 
 *  while handling this event will cancel the screen change.
 * 
 *  @eventType mx.events.ViewNavigatorEvent.REMOVING
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="removing", type="spark.events.ViewNavigatorEvent")]

/**
 *  The View class is the base container class for all Views used by view
 *  navigators.  The View container extends <code>Group</code> and adds
 *  additional properties that are used to communicate with it's parent
 *  navigators' various ui controls.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class View extends SkinnableContainer implements IDataRenderer
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function View()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  active
    //----------------------------------
    
    private var _active:Boolean = false;
    
    /**
     *  Flag indicating whether the current screen is active.  The view's navigator will 
     *  automatically set this flag to true or false as its state changes.  This getter 
     *  will dispatch <code>FlexEvent.VIEW_ACTIVATE</code> and 
     *  <code>FlexEvent.VIEW_DEACTIVATE</code> as the value changes.
     *  
     *  @default false
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get isActive():Boolean
    {
        return _active;
    }
    
    /**
     * @private
     */
    mx_internal function setActive(value:Boolean):void
    {
        if (_active != value)
        {
            _active = value;
            
            var eventName:String = _active ? 
                ViewNavigatorEvent.VIEW_ACTIVATE : 
                ViewNavigatorEvent.VIEW_DEACTIVATE;
            
            if (hasEventListener(eventName))
                dispatchEvent(new ViewNavigatorEvent(eventName, false, false, navigator.lastAction));
        }
    }

    //----------------------------------
    //  canRemove
    //----------------------------------
    
    /**
     *  @private
     *  Determines if the current view can be removed by a navigator.  The default 
     *  implementation dispatches a <code>FlexEvent.REMOVING</code> event.  If
     *  preventDefault() is called on the event, this property will return false.
     * 
     *  @return Returns true if the view can be removed
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    mx_internal function canRemove():Boolean
    {
        if (hasEventListener(ViewNavigatorEvent.REMOVING))
        {
            var event:ViewNavigatorEvent = 
                new ViewNavigatorEvent(ViewNavigatorEvent.REMOVING, 
                                       false, true, navigator.lastAction);
            
            return dispatchEvent(event);
        }
        
        return true;
    }
    
    /**
     *  @private
     */ 
    mx_internal function backKeyHandledByView():Boolean
    {
        if (hasEventListener(FlexEvent.BACK_KEY_PRESSED))
        {
            var event:FlexEvent = new FlexEvent(FlexEvent.BACK_KEY_PRESSED, false, true);
            var eventCanceled:Boolean = !dispatchEvent(event);
            
            // If the event was canceled, that means the application
            // is doing its own custom logic for the back key
            return eventCanceled;
        }
        
        return false;
    }
    
    /**
     *  @private
     */ 
    mx_internal function menuKeyHandledByView():Boolean
    {
        if (hasEventListener(FlexEvent.MENU_KEY_PRESSED))
        {
            var event:FlexEvent = new FlexEvent(FlexEvent.MENU_KEY_PRESSED, false, true);
            var eventCanceled:Boolean = !dispatchEvent(event);
            
            // If the event was canceled, that means the application
            // is doing its own custom logic for the back key
            return eventCanceled;
        }
        
        return false;
    }
    
    //----------------------------------
    //  overlayControls
    //----------------------------------
    
    private var _overlayControls:Boolean = false;
    
    [Inspectable(category="General", defaultValue="false")]
    /**
     *  Determines the way the view's navigator's ui controls
     *  should lay out in relation to the view content.  If
     *  set to true, the ui controls will hover on top of the
     *  view.
     *  
     *  @default false
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get overlayControls():Boolean
    {
        return _overlayControls;
    }
    
    /**
     *  @private
     */
    public function set overlayControls(value:Boolean):void
    {
        if (_overlayControls != value)
        {
            var oldValue:Boolean = _overlayControls;
            _overlayControls = value;
            
            if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
            {
                var changeEvent:PropertyChangeEvent = 
                PropertyChangeEvent.createUpdateEvent(this, "overlayControls", oldValue, _overlayControls);
            
                dispatchEvent(changeEvent);
            }
        }
    }
    
    //----------------------------------
    //  destructionPolicy
    //----------------------------------
    
    [Inspectable(category="General", enumeration="auto,never", defaultValue="auto")]
    /**
     *  Defines the destruction policy the view's navigator should use
     *  when this view is removed. If set to "auto", the navigator will
     *  destroy the view when it isn't active.  If set to "never", the
     *  view will be cached in memory.
     * 
     *  @default auto
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var destructionPolicy:String = ContainerDestructionPolicy.AUTO;
    
    //----------------------------------
    //  navigator
    //----------------------------------
    
    private var _navigator:ViewNavigator = null;
    
    /**
     * The navigator that the view resides in.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    
    public function get navigator():ViewNavigator
    {
        return _navigator;
    }
    
    /**
     *  @private
     */ 
    mx_internal function setNavigator(value:ViewNavigator):void
    {
        _navigator = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  UI Template Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  actionBarVisible
    //----------------------------------
    private var _actionBarVisible:Boolean = true;
    
    [Inspectable(category="General", defaultValue="true")]
    /**
     *  Flag indicating whether a view should show the action bar or not.
     *  This doesn't necessarily correlate to the visible property of the
     *  navigator's ActionBar.  In the end, ViewNavigator and the developer
     *  have the last say as to what's visible.
     *
     *  @default true
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get actionBarVisible():Boolean
    {
        return _actionBarVisible;
    }
    
    /**
     *  @private
     */ 
    public function set actionBarVisible(value:Boolean):void
    {
        _actionBarVisible = value;
        
        // Immediately request actionBar's visibility be toggled
        if (isActive && navigator)
        {
            if (_actionBarVisible)
                navigator.showActionBar();
            else
                navigator.hideActionBar();
        }
    }
    
    /**
     *  @private
     *  Method called by parent navigator to update the actionBarVisible
     *  flag as a result of the showActionBar() or hideActionBar() methods.
     */ 
    mx_internal function setActionBarVisible(value:Boolean):void
    {
        _actionBarVisible = value;
    }
    
    //----------------------------------
    //  actionContent
    //----------------------------------
    
    private var _actionContent:Array;
    
    [ArrayElementType("mx.core.IVisualElement")]
    /**
     *  Array of visual elements that are used as the ActionBar's
     *  actionContent when this view is active.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get actionContent():Array
    {
        return _actionContent;
    }
    /**
     *  @private
     */
    public function set actionContent(value:Array):void
    {
        var oldValue:Array = _actionContent;
        _actionContent = value;
        
        if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
        {
            var changeEvent:PropertyChangeEvent = 
                PropertyChangeEvent.createUpdateEvent(this, "actionContent", oldValue, _actionContent);
        
            dispatchEvent(changeEvent);
        }
    }
    
    //----------------------------------
    //  actionLayout
    //----------------------------------
    
    /**
     *  Layout for the ActionBar's action content group.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private var _actionLayout:LayoutBase;
    
    public function get actionLayout():LayoutBase
    {
        return _actionLayout;
    }
    /**
     *  @private
     */
    public function set actionLayout(value:LayoutBase):void
    {
        var oldValue:LayoutBase = value;
        _actionLayout = value;
        
        if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
        {
            var changeEvent:PropertyChangeEvent = 
                PropertyChangeEvent.createUpdateEvent(this, "actionLayout", oldValue, _actionLayout);
        
            dispatchEvent(changeEvent);
        }
    }
    
    //----------------------------------
    //  viewMenuItems
    //----------------------------------
    
    private var _viewMenuItems:Vector.<ViewMenuItem>;
    
    /**
     *  The Vector of ViewMenuItems that are passed to the ViewMenu when
     *  this View is the active view. 
     */   
    public function get viewMenuItems():Vector.<ViewMenuItem>
    {
        return _viewMenuItems;
    }
    
    public function set viewMenuItems(value:Vector.<ViewMenuItem>):void
    {
        _viewMenuItems = value;
    }
    
    //----------------------------------
    //  navigationContent
    //----------------------------------
    
    private var _navigationContent:Array;
    
    [ArrayElementType("mx.core.IVisualElement")]
    /**
     *  Array of visual elements that are used as the ActionBar's
     *  navigationContent when this view is active.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get navigationContent():Array
    {
        return _navigationContent;
    }
    /**
     *  @private
     */
    public function set navigationContent(value:Array):void
    {
        var oldValue:Array = _navigationContent;
        _navigationContent = value;
        
        if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
        {
            var changeEvent:PropertyChangeEvent = 
                PropertyChangeEvent.createUpdateEvent(this, "navigationContent", oldValue, _navigationContent);
        
            dispatchEvent(changeEvent);
        }
    }
    
    //----------------------------------
    //  navigationLayout
    //----------------------------------
    
    private var _navigationLayout:LayoutBase;
    
    /**
     *  Layout for the ActionBar navigation content group.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get navigationLayout():LayoutBase
    {
        return _navigationLayout;
    }
    /**
     *  @private
     */
    public function set navigationLayout(value:LayoutBase):void
    {
        var oldValue:LayoutBase = _navigationLayout;
        _navigationLayout = value;
        
        if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
        {
            var changeEvent:PropertyChangeEvent = 
                PropertyChangeEvent.createUpdateEvent(this, "navigationLayout", _navigationLayout, value);
        
            dispatchEvent(changeEvent);
        }
    }
	

    
	//----------------------------------
	//  tabBarVisible
	//----------------------------------
	private var _tabBarVisible:Boolean = true;
    
    [Inspectable(category="General", defaultValue="true")]
	/**
	 *  Flag indicating whether a view should show the action bar or not.
	 *  This doesn't necessarily correlate to the visible property of the
	 *  navigator's ActionBar.  In the end, ViewNavigator and the developer
	 *  have the last say as to what's visible.
	 *
	 *  @default true
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
	 */
	public function get tabBarVisible():Boolean
	{
		return _tabBarVisible;
	}
    
    /**
     *  @private
     */
	public function set tabBarVisible(value:Boolean):void
	{
        var oldValue:Boolean = _tabBarVisible;
		_tabBarVisible = value;
		
		// Immediately request actionBar's visibility be toggled
		if (isActive && navigator)
		{
            if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
            {
                var changeEvent:PropertyChangeEvent = 
                    PropertyChangeEvent.createUpdateEvent(this, "tabBarVisible", oldValue, value);
                
                dispatchEvent(changeEvent);
            }
		}
	}
    
    /**
     *  @private
     *  Method called by parent navigator to update the actionBarVisible
     *  flag as a result of the showTabBar() or hideTabBar() methods.
     */ 
    mx_internal function setTabBarVisible(value:Boolean):void
    {
        _tabBarVisible = value;
    }
    
    //----------------------------------
    //  title
    //----------------------------------
    
    private var _title:String;
    
    [Bindable]
    /**
     *  The title for the view.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    public function get title():String
    {
        return _title;
    }
    /**
     *  @private
     */ 
    public function set title(value:String):void
    {
        if (_title != value)
        {
            var oldValue:String = _title;            
            _title = value;
            
            if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
            {
                var changeEvent:PropertyChangeEvent = 
                    PropertyChangeEvent.createUpdateEvent(this, "title", oldValue, _title);
            
                dispatchEvent(changeEvent);
            }
        }
    }
    
    //----------------------------------
    //  titleContent
    //----------------------------------
    
    private var _titleContent:Array;
    
    [ArrayElementType("mx.core.IVisualElement")]
    /**
     *  Array of visual elements that are used as the ActionBar's
     *  titleContent when this view is active.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get titleContent():Array
    {
        return _titleContent;
    }
    /**
     *  @private
     */
    public function set titleContent(value:Array):void
    {
        var oldValue:Array = _titleContent;
        _titleContent = value;
        
        if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
        {
            var changeEvent:PropertyChangeEvent = 
                PropertyChangeEvent.createUpdateEvent(this, "titleContent", oldValue, _titleContent);
            
            dispatchEvent(changeEvent);
        }
    }
    
    //----------------------------------
    //  titleLayout
    //----------------------------------
    
    /**
     *  Layout for the ActionBar's titleContent group.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private var _titleLayout:LayoutBase;
    
    public function get titleLayout():LayoutBase
    {
        return _titleLayout;
    }
    /**
     *  @private
     */
    public function set titleLayout(value:LayoutBase):void
    {
        var oldValue:LayoutBase = _titleLayout;
        _titleLayout = value;
        
        if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
        {
            var changeEvent:PropertyChangeEvent = 
                PropertyChangeEvent.createUpdateEvent(this, "titleLayout", oldValue, _titleLayout);
            
            dispatchEvent(changeEvent);
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  IDataRenderer Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  data
    //----------------------------------
    
    private var _data:Object;
    
    [Bindable("dataChange")]
    
    /**
     *  The data associated with the current view.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get data():Object
    {
        return _data;
    }
    
    /**
     *  @private
     */ 
    public function set data(value:Object):void
    {
        _data = value;
        
        if (hasEventListener(FlexEvent.DATA_CHANGE))
            dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Methods creates an object that should be returned to the
     *  previous screen when this view is popped off a navigator's
     *  stack.
     * 
     *  @return null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function createReturnObject():Object
    {
        return null;
    }
    
    /**
     *  Checks the aspect ratio of the stage and returns the proper state
     *  that the View should change to.  The possible values are either "portrait"
     *  or "landscape".  The state is only changed if the desired state exists
     *  on the View. If it does not, this method will return the component's
     *  current state.
     * 
     *  @return A String specifying the name of the state to apply to the view. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function getCurrentViewState():String
    {
        var aspectRatio:String = FlexGlobals.topLevelApplication.aspectRatio;
        
        if (hasState(aspectRatio))
            return aspectRatio;
        
        // If the appropriate state for the orientation of the device
        // isn't defined, return the current state
        return currentState;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------
    /**
     *  @private
     */ 
    private function stage_orientationChangeHandler(event:StageOrientationEvent):void
    {
        if (isActive)
        	setCurrentState(getCurrentViewState(), false);
    }
    
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: UIComponent
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */ 
    override public function initialize():void
    {
    	super.initialize();
        
        addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
    }
    
    /**
     *  @private
     */ 
    private function creationCompleteHandler(event:FlexEvent):void
    {
        removeEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
        
        // Create a weak listener so stage doesn't hold a reference to the view
        systemManager.stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGE, 
            stage_orientationChangeHandler, false, 0, true);
        
        setCurrentState(getCurrentViewState(), false);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Persistence Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Responsible for serializes the view's data object when the view is being
     *  persisted to disk.  The created object should be something that can
     *  be successfully written to a shared object.  By default, this will return 
     *  the data object of the view.
     * 
     *  @return The serialized data object.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function serializeData():Object
    {
        return data;    
    }
    
    /**
     *  Deserializes a data object that was saved to disk by the view.  The
     *  returned object will be the value assigned to the view's data object.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function deserializeData(value:Object):Object
    {
        return value;
    }
}
}