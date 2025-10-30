%SusLLTDCalc

%{
From RCVD 16.2:


%}

%input parameters:

w_total = [600]; %Total weight {lbf}
m_total = w_total; %Total mass {lbm}
z_cog = [11.5/12]; %Vertical height of CoG from ground {ft}
z_frc = [2.165/12]; %height of FRC {ft}
z_rrc = [3.031/12]; %height of RRC {ft}
tw_f = [48.174/12]; %track width, front {ft}
tw_r = [48.174/12]; %track width, rear {ft}
fr_wd = [0.50]; %front/rear dist. weight distrib. {ft/ft}
a_y = [-1.5]; %lat. accel. {gee}
K_phi_f = [18600/(180/pi)]; %Front Roll Rate {lb-ft/deg}   WHERE IS THIS VALUE COMING FROM
K_phi_r = [15500/(180/pi)]; %Rear Roll Rate {lb-ft/deg}     
wb = 61.10/12; %Wheelbase {in}

wctrvl_accptbl_c_f = [1.06/12]; %acceptable wheel center travel, compression, front {ft}   WHERE 1.06 FROM?
wctrvl_accptbl_c_r = []; %"          "     "      "       "          , rear {ft}
wctrvl_accptbl_r_f = []; %"          "     "      "       rebound    , front {ft}
wctrvl_accptbl_r_r = []; %"          "     "      "       "          , rear {ft}
wctrvl_accptbl_c = 1.625; %inches

%intermediates:

dz_cog_frc = z_cog - z_frc; %vert. dist. b/w CoG and front roll axis {ft}
dz_cog_rrc = z_cog - z_rrc; %vert. dist. b/w CoG and rear roll axis {ft}
%x_cog_f_perwb = (1./(1+fr_wd)); ? IGNORE: fr_wd is distance distrib instead of wt distrib?
x_cog_perwb_f = 1-fr_wd; %X dist. from CoG to front axle per wheelbase length {ft/ft} 
%x_cog_r_perwb = 1-x_cog_f_perwb; 
x_cog_perwb_r = fr_wd; %X dist. from CoG to rear axle per wheelbase length {ft/ft}
K_phi_t = K_phi_f + K_phi_r; %Total roll rate {lb-ft/deg}
w_axle_f = w_total .* x_cog_perwb_f; %front axle weight {lbf}
w_axle_r = w_total .* x_cog_perwb_r; %rear axle weight {lbf}

angle_rc = atand((z_rrc-z_frc)/wb)
u = tand(angle_rc)*(wb/2)
cg_to_rollaxis = (z_cog-z_frc)-u %distance from CG to intersection of roll axis {ft}

%TODO TODO TODO:
%F/R weight distribution x_cog_perwb_f should be opposite

roll_gradient_front = (-w_total .* (dz_cog_frc)) ./ (K_phi_t); %Roll gradient (front) {deg/g}
roll_gradient_rear = (-w_total .* (dz_cog_rrc)) ./ (K_phi_t); %Roll gradient (rear) {deg/g}
roll_gradient = (-w_total.*cg_to_rollaxis)./(K_phi_t) %Total roll Axis???? im confused

%Weight transfer outputs:

Wt_f = a_y .* (w_total./tw_f) .* ( ((cg_to_rollaxis.*K_phi_f)./(K_phi_t))...
    + (x_cog_perwb_r).*(z_frc) ) %Weight Transfer due to lat. accel. {lbf/gee} SHOULD THIS JUST BE lbf?
Wt_r = a_y .* (w_total./tw_r) .* ( ((cg_to_rollaxis.*K_phi_r)./(K_phi_t))...
    + (x_cog_perwb_f).*(z_rrc) ) %Weight Transfer due to lat. accel. {lbf/gee}

%wheel loads during given lateral accel. (assuming no banking!!):
wl_fo = w_axle_f./2 - Wt_f %wheel load, front outer {lbf}
wl_fi = w_axle_f./2 + Wt_f %"     ",    "     inner {lbf}
wl_ro = w_axle_r./2 - Wt_r; %"     ",    rear  outer {lbf}
wl_ri = w_axle_r./2 + Wt_r; %"     ",    "     inner {lbf}

%wheel load change from our static load. (How much extra "weight is on each tire)
wl_fo_s = wl_fo - (w_axle_f/2)
wl_fi_s = wl_fi - (w_axle_f/2);
wl_ro_s = wl_ro - (w_axle_r/2)
wl_ri_s = wl_ri - (w_axle_r/2);

%required ride rates to not bottom out given lltd and max comp. travel:
K_ride_req_fv = wl_fo_s./wctrvl_accptbl_c; %Required ride rate for front {lbf/in}
K_ride_req_rv = wl_ro_s./wctrvl_accptbl_c; %"        "    "    "   rear {lbf/in}


%required ride rates to not bottom out given lltd and max comp. travel:
% K_ride_req_f = max(abs([wl_fo,wl_fi]))./wctrvl_accptbl_c_f; %Required ride rate for front {lbf/ft}
% K_ride_req_r = max(abs([wl_ro,wl_ri]))./wctrvl_accptbl_c_r; %"        "    "    "   rear {lbf/ft}

%ride frequencies:
ridefreq_f = (1/(2*pi)) .* (sqrt((K_ride_req_fv.*12.*32.2)./(w_axle_f./2))) %front ride freq. {Hz}
ridefreq_r = (1/(2*pi)) .* (sqrt((K_ride_req_rv.*12.*32.2)./(w_axle_r./2))) %front ride freq. {Hz}


%{ 
From RCVD 16.2:
Wt_f = a_y * (w_total / tw_f) * ( ((dz_cog_frc * K_phi_f) / (K_phi_t))...
 + (x_cog_r / wb)*(z_frc) )

Wt_r = a_y * (w_total / tw_r) * ( ((dz_cog_rrc * K_phi_r) / (K_phi_t))...
 + (x_cog_f / wb)*(z_rrc) )


%}





%printing outputs:
% fprintf("\nWeight Transfer {lbf}:\nFront: %18.4E\nRear: %19.4E\n",Wt_f, Wt_r);
% fprintf("\nWheel Loads {lbf}:\nFront Outer: %12.4E\nFront Inner: %12.4E"+...
% "\nRear Outer: %13.4E\nRear Inner: %13.4E\n", wl_fo, wl_fi, wl_ro, wl_ri);
% fprintf("\nRequired Ride Rates {lbf/in}:\nFront: %10.4E\nRear: %10.4E\n", K_ride_req_fv,K_ride_req_rv);
% fprintf("\nRide Frequencies {Hz}:\nFront: %10.4E\nRear: %10.4E\n", ridefreq_f, ridefreq_r);