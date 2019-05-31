function g = logvalley(img,p)
% Edge/valley detection function, a combination of the 'valley detection' 
% and 'LoG' algorithms
% 
% - p.edgemode = 'none', 'log', 'valley', 'logvalley', 'clogvalley' or 
%   0,1,2,3,5 - the mode of operation: 'logvalley' combines the two
%   algorithms, while 'clogvalley' only returns the 'cross' edge, requiring
%   the product of the Laplacian and valley depth to be above threshold
% - p.edgeSigmaL - sigma of Gaussian smoothing kernel for LoG
% - p.logthresh - minimum surface curvature (Laplacian) to consider a pixel
%   a part of the edge
% - p.edgeSigmaV - sigma of Gaussian smoothing kernel for Valley
% - p.valleythresh2 - a 'hard' threshold for Valley, minimum "depth" of the
%   valley to be detected (and excluded from cells)
% - p.valleythresh1 - a 'soft' one, meaning that the pixel is only detected
%   as a part of a valley if it's connected (by a chain of length up to 3)
%   to a pixel above the hard threshold
% - p.crossthresh - threshold for the product of the Laplacian and valley
%   depth

  mode = p.edgemode;
  if isnumeric(mode)
      if mode==0, mode='none';
      elseif mode==1, mode='log'; % Laplacian of Gaussian (LoG) edge detection
      elseif mode==2, mode='valley'; % Valley (ridge) detection
      elseif mode==3, mode='logvalley'; % Both LoG and Valley detection
      elseif mode==4, mode='clogvalley'; % Cross of LoG and Valley with common threshold
      end
  end
  img = 1-im2single(img);
  [m,n] = size(img);
  
  if strcmp(mode,'log') || strcmp(mode,'logvalley') || strcmp(mode,'clogvalley')
      % LoG edge  detection
      if isfield(p,'edgeSigmaL')&&p.edgeSigmaL>=0.01, edgeSigmaL=p.edgeSigmaL; else edgeSigmaL=0.01; end
      if isfield(p,'logthresh'), logthresh=p.logthresh; else logthresh=0; end
      fsize = ceil(edgeSigmaL*3)*2 + 1;  % choose an odd fsize > 6*edgeSigmaL;
      op = fspecial('log',fsize,edgeSigmaL); 
      op = op - sum(op(:))/numel(op); % make the op to sum to zero
      b = imfilter(img,op,'replicate');
      stdb = std(b(:));
      e = b>logthresh*stdb;
      se = strel('arbitrary',ones(3));
      e = imdilate(e&~bwmorph(e,'endpoints'),se)&e;
      if isempty(p.valleythresh1), p.valleythresh1 = .75*mean2(abs(b)); end
  end
  if strcmp(mode,'valley') || strcmp(mode,'logvalley') || strcmp(mode,'clogvalley')
      % Valley detection
      se = strel('arbitrary',ones(3));
      rr = 2:m-1; 
      cc = 2:n-1;
      if isfield(p,'valleythresh1')&&~isempty(p.valleythresh1), valleythresh1=p.valleythresh1; else p.valleythresh1=0; end
      if length(valleythresh1)>1, valleythresh1 = valleythresh1(rr,cc); end
      if isfield(p,'valleythresh2')&&~isempty(p.valleythresh2), valleythresh2=p.valleythresh2; else p.valleythresh2=0; end
      valleythresh2 = max(valleythresh2,0);
      valleythresh1 = min(max(valleythresh1,0),valleythresh2);
      if isfield(p,'edgeSigmaV')&&p.edgeSigmaV>0
          fsize = ceil(p.edgeSigmaV*3)*2 + 1;
          op = fspecial('gaussian',fsize,p.edgeSigmaV); 
          op = op/sum(sum(op));
          img = imfilter(img,op,'replicate');
      end
      f = zeros(m,n);
      f(rr,cc) = max(max(min(img(rr,cc-1)-img(rr,cc),img(rr,cc+1)-img(rr,cc)), ...
                         min(img(rr-1,cc)-img(rr,cc),img(rr+1,cc)-img(rr,cc))), ...
                     max(min(img(rr-1,cc-1)-img(rr,cc),img(rr+1,cc+1)-img(rr,cc)), ...
                         min(img(rr+1,cc-1)-img(rr,cc),img(rr-1,cc+1)-img(rr,cc))));
      fmean = mean(f(f>quantile(f(f>0),0.99)));
      f1 = f>fmean*valleythresh1;
      f2 = f>fmean*valleythresh2;
      for i=1:4, f2 = f1 & imdilate(f2,se); end
  end
  if (strcmp(mode,'logvalley') || strcmp(mode,'clogvalley')) && isfield(p,'crossthresh') && p.crossthresh>0
      c = b.*(f+fmean)>stdb*fmean*p.crossthresh;
  else
      c = false;
  end
  if strcmp(mode,'log') || strcmp(mode,'flog')
      g = e;
  elseif strcmp(mode,'valley')
      g = f2;
  elseif strcmp(mode,'logvalley')
      g = e | f2 | c;
  elseif strcmp(mode,'clogvalley')
      g = c;
  else
      g = false(m,n);
  end