      % P is a "parameter" matrix, representing experimental design (lotteries).  
      %rows are trials, column 1 is x1, column 2 is x2 
      %column 3 is Pr(x1), column 4 is the binary choice variable: y value
      %
      %x is the prospect theory param. vector, in the order, lambda, rho, mu
      
      function f = loglikelihood_rhomulam_effort(x,P)
      f = 0;
      
      %sum log likelihood for each observation (trial)
      for i=1:1:length(P)
         
          %xb is the "index" of the binary choice model, eg: expected
          %utility
          %xb= x(1) * ((.5*P(i,2)^x(2)) - (P(i,1)^x(2)));
          xb = x(1) * (  (P(i,1)^x(2)) - ( 0.5*(P(i,2)^x(2)) ));
          %xb=x(1)*((.5*P(i,2))+(.5*x(2)*P(i,3));
          
          %if choice value is 1, use one part of likelihood contribution.
          if(P(i,3)==1)
              f=f+log((1+exp(-1*xb))^-1);
                  
          %if choice value is 0, use other part of likelihood contribution    
          elseif(P(i,3)==0)
             f=f+log(1-(1+exp(-1*xb))^-1);
          
          end
      end
      f=f*-1;
          

