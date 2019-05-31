function g = logvalley(img,mode,sigmaL,sigmaV,thresh1,thresh2)
% a combination of the 'valley detection' and 'LoG' algorithms
% 
% mode = 'none', 'log', 'valley', 'logvalley' or 0,1,2,3
% thresh2 is a 'hard' threshold, thresh1 - a 'soft' one, meaning that the
% pixel is only detected as a part of a valley if it's adjasent to a
% pixel above the hard threshold.

  if isnumeric(mode)
      if mode==0, mode='none';
      elseif mode==1, mode='log';
      elseif mode==2, mode='valley';
      elseif mode==3, mode='logvalley';
      end
  end
  img = 1-im2single(img);
  [m,n] = size(img);
  
  if strcmp(mode,'log') || strcmp(mode,'logvalley')
      % LoG edge  detection
      if sigmaL<0.01, sigmaL=0.01; end
      fsize = ceil(sigmaL*3)*2 + 1;  % choose an odd fsize > 6*sigmaL;
      op = fspecial('log',fsize,sigmaL); 
      op = op - sum(op(:))/numel(op); % make the op to sum to zero
      b = imfilter(img,op,'replicate');
      e = b>0;
      se = strel('arbitrary',ones(3));
      e = imdilate(e&~bwmorph(e,'endpoints'),se)&e;
      if isempty(thresh1), thresh1 = .75*mean2(abs(b)); end
  end
  if strcmp(mode,'valley') || strcmp(mode,'logvalley') || strcmp(mode,'flogvalley')
      % Valley detection
      se = strel('arbitrary',ones(3));
      rr = 2:m-1; 
      cc = 2:n-1;
      if isempty(thresh1), thresh1 = 0; end
      if length(thresh1)>1, thresh1 = thresh1(rr,cc); end
      if isempty(thresh2), thresh2 = 0; end
      thresh2 = max(thresh2,0);
      thresh1 = min(max(thresh1,0),thresh2);
      if sigmaV>0
          fsize = ceil(sigmaV*3)*2 + 1;
          op = fspecial('gaussian',fsize,sigmaV); 
          op = op/sum(sum(op));
          img = imfilter(img,op,'replicate');
      end
      f = zeros(m,n);
      f(rr,cc) = max(max(min(img(rr,cc-1)-img(rr,cc),img(rr,cc+1)-img(rr,cc)), ...
                         min(img(rr-1,cc)-img(rr,cc),img(rr+1,cc)-img(rr,cc))), ...
                     max(min(img(rr-1,cc-1)-img(rr,cc),img(rr+1,cc+1)-img(rr,cc)), ...
                         min(img(rr+1,cc-1)-img(rr,cc),img(rr-1,cc+1)-img(rr,cc))));
      fmean = mean(f(f>quantile(f(f>0),0.99)));
      f1 = f>fmean*thresh1;
      f2 = f>fmean*thresh2;
      for i=1:4, f2 = f1 & imdilate(f2,se); end
  end
  if strcmp(mode,'log') || strcmp(mode,'flog')
      g = e;
  elseif strcmp(mode,'valley')
      g = f2;
  elseif strcmp(mode,'logvalley') || strcmp(mode,'flogvalley')
      g = e | f2;
  else
      g = false(m,n);
  end