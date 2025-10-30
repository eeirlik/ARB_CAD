%ARB Spring Rate and Roll Rate Contribution Calc.

%{
From RCVD 16.3, pg 599:

K_phiB = K_thetaB_deg * I_B^2 * (Tw^2 / L_lever ^2)
Where:
K_phiB: ARB Contrib. to car roll rate {lb-ft/deg}
K_thetaB_deg: ARB angular spring rate {lb-ft/deg}
I_B: Install. ratio of ARB; lever arm connect. displacement/wheel center displacement {in./in.}
Tw: Track width {ft.}

%}


%{
Angular Rate of Torsion bar:

K_thetaB_rad = G * J / L_bar
Where:
K_thetaB_rad: Angular Rate of Torsion Bar {lb-ft/rad}

J: Torsional constant => polar second moment of area {ft^4}
    For hollow tube: J = (pi/2) * (r_out^4 - r_in^4)
L_bar: Length of bar {ft}

%}

%Input Parameters:
G_bar = []; %G_bar: Modulus of Rigidity of material {lbf/ft^2}
L_bar = []; %L_bar: Length of torsion bar {ft}
r_outer = []; %r_outer: outer radius of torsion bar {ft}
r_inner = []; %r_inner: inner radius of torsion bar {ft}
Tw = []; %Track width: {ft}

J_bar = (pi/2) .* (r_outer.^4 - r_inner.^4); %For hollow tube: J {ft^4} = (pi/2) * (r_outer^4 - r_inner^4) {ft^4}
K_thetaB_rad = G_bar .* J_bar ./ L_bar;
K_thetaB_deg = K_thetaB_rad .* (pi/180); % K_thetaB_deg {lb-ft/deg} = K_thetaB_rad {lb-ft/rad} * pi/180 {rad/deg}

K_phiB = K_thetaB_deg .* I_B.^2 .* (T_w.^2 ./ L_lever.^2); 