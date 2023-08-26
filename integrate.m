%############################################################################
%#
%#                          function INTEGRATE
%#
%#      simple numerical integration (subsequent sum) of 1D data
%#
%#      usage: int=integrate(data);
%#    
%#      (c) P. Blümler 1/03
%############################################################################
%----------------------------------------------------------------------------
%  version 1.2 PB 23/10/03    (added division at end)
%----------------------------------------------------------------------------


  function result=integrate(data)
  data=squeeze(data);
  %dim=dimension(data);
  dim=1;

  if dim ~= 1
      errordlg('ERROR: data input array is NOT ONEDIMENSIONAL!');
      return
  end
  result=data;
  n_points=length(data);
  for t=2:n_points
      result(t)=result(t-1)+data(t);
  end
  result=result/n_points;
  