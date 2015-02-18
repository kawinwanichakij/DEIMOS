function Ez, z

   distance = 1/sqrt(0.3*(1+z)^3+0.7)
   return, distance

end

pro imagtoextinction, cat, outcat

	; read in the data to be extinction corrected
	readcol, cat, format='A,A,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D', mask, slit, z, EWHa, EWHaerr, EWOII, EWOIIerr, FHa, FHaerr, FNII, FNIIerr, rmag, imag, zmag, f606, f814, ra, dec, /silent

	; Now read in the K-correction catalog generated by the spectral K-correct code
	readcol, '1604members_Bvsi_fromDEIMOS.dat', format='A,D,D,D,A,A,D,D,D,D,D,D,D', ID, racat, deccat, zcat, maskcat, slitcat, rmagcat, imagcat, zmagcat, f606cat, f814cat, imagspec, Bmagspec, /silent

	catindex = intarr(n_elements(mask))

	for i=0, n_elements(mask)-1 do begin
		catindex[i] = where(mask[i] eq maskcat and slit[i] eq slitcat)
	endfor
	
	itoBKcorr = imagspec[catindex] - Bmagspec[catindex] 	;the K-correction between the apparent B mag and apparent i' mag as calculated from the DEIMOS spectrum


	mB = imag - itoBKcorr		;is - because of the way I defined K
	
	Dcnorm = qromb('Ez', 0.0, z)	
	Dc = 4.28571e9*Dcnorm	;assuming h = 0.7, Dc is in [pc]
	lumdist = double((1+z)*Dc)

	
	absolute_MB = mB - 5.*alog10(lumdist/10)	;get absolute B-band mag from d_L and m_B

	BminusVextinction = -0.0625*absolute_MB - 0.925		;E(B-V) from the relationship of Jansen 2001 

	AHa = 3.326*BminusVextinction			;correction in magnitudes for extinction at Ha, derived from formulae of Calzetti 2000 at Ha rest wavelength, astro-ph/9911459
	AHa_err =  0.80*BminusVextinction

	AOII = 5.858*BminusVextinction                   ;correction in magnitudes for extinction at OII, derived from formulae of Calzetti 2000 at OII rest wavelength, astro-ph/9911459
        AOII_err =  0.80*BminusVextinction
	
	Hafluxcorr = 10^(AHa/2.5)
	Hafluxcorrposerr = 10^((AHa+AHa_err)/2.5) - Hafluxcorr
	Hafluxcorrnegerr = Hafluxcorr- 10^((AHa - AHa_err)/2.5)
	
	OIIfluxcorr = 10^(AOII/2.5)
        OIIfluxcorrposerr = 10^((AOII+AOII_err)/2.5) - OIIfluxcorr
        OIIfluxcorrnegerr = OIIfluxcorr- 10^((AHa - AOII_err)/2.5)

	openw, lun, outcat, width=300, /get_lun
	printf, lun, 'mask    slit    M_B    A_Ha     A_Ha_err    A_OII    A_OII_err    F(Ha) correction   F(Ha) corr poserr    F(Ha) corr negerr  F(OII) correction   F(OII) corr poserr    F(OII) corr negerr'
	for i=0, n_elements(mask)-1 do begin

		printf, lun, mask[i], '   ', slit[i], '   ', absolute_MB[i], '   ', AHa[i], '   ', AHa_err[i], '   ', AOII[i], '   ', AOII_err[i], '   ', Hafluxcorr[i], '   ', Hafluxcorrposerr[i], '   ', Hafluxcorrnegerr[i], '   ', OIIfluxcorr[i], '   ', OIIfluxcorrposerr[i], '   ', OIIfluxcorrnegerr[i]
	endfor

	free_lun, lun

end	 

	
	