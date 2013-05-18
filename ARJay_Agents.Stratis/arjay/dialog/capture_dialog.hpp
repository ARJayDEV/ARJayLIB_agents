// missionConfigFile >> "ARJAY_CAPTURE_DIALOG"

class ARJAY_CAPTURE_DIALOG
{
	idd = -1;
	movingEnable = false;
	enableSimulation = true;
	fadeIn = 1;
	fadeOut = 1;
	duration = 30;
	onLoad = "uiNamespace setVariable ['ARJAY_CAPTURE_DIALOG', _this select 0]";
	
	class Controls
	{		
		class ARJAY_BG: IGUIBack
		{
			idc = -1;
			x = 51 * GUI_GRID_W + GUI_GRID_X;
			y = 29.2 * GUI_GRID_H + GUI_GRID_Y;
			w = 12 * GUI_GRID_W;
			h = 5.5 * GUI_GRID_H;
			colorBackground[] = {ARJAY_C_BLACK, ARJAY_BG_ALPHA};
		};
		class ARJAY_BTN: RscText
		{
			idc = 1001;
			text = "TITLE";
			x = 51.2 * GUI_GRID_W + GUI_GRID_X;
			y = 29.4 * GUI_GRID_H + GUI_GRID_Y;
			w = 11.6 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			colorText[] = {ARJAY_C_WHITE, ARJAY_TEXT_ALPHA};
		};
		class ARJAY_STR_TEXT: RscStructuredText
		{
			idc = 1002;
			text = "CONTENT";
			x = 51.3 * GUI_GRID_W + GUI_GRID_X;
			y = 30.4 * GUI_GRID_H + GUI_GRID_Y;
			w = 4.5 * GUI_GRID_W;
			h = 3.5 * GUI_GRID_H;
			colorText[] = {ARJAY_C_WHITE, ARJAY_TEXT_ALPHA};
			class Attributes {
				size = "1.8";
			};
		};
		class ARJAY_IMG_FLAG: RscPicture
		{
			idc = -1;
			text = "arjay\dialog\flag.paa";
			x = 58 * GUI_GRID_W + GUI_GRID_X;
			y = 30.3 * GUI_GRID_H + GUI_GRID_Y;
			w = 4.5 * GUI_GRID_W;
			h = 3.5 * GUI_GRID_H;
			colorText[] = {ARJAY_C_WHITE, 1};
		};
	};
};
