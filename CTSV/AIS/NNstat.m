# this function take a raw 40 element vector 
# of stats for the DSGE model and outputs
# the fitted 300_40.jl neural net fittted 
# value
# Z enters as a row vector, output stat is also a row vector
function fit = NNstat(Z)
        # load the preprocess items and NN coefs
        load mZs;
        load sZs;
        load sErrors;
        load alpha1;
        load alpha2;
        load alpha3;
        load beta;
        load beta1;
        load beta2;
        load beta3;
        # get the NN fit
        x = (Z - mZs) ./ sZs;
        preprocess = [ones(size(x,1),1) x]*beta;
        h1 = tanh(alpha1' + x*beta1);
        h2 = tanh(alpha2' + h1*beta2);
        fit = alpha3' + h2*beta3;
        fit = fit.*sErrors + preprocess;
        fit = fit(:,1:6);
        parameters;
        lb = lb_ub(1:6,1)';
        ub = lb_ub(1:6,2)';
        test = fit >= lb;
        fit = fit.*test + lb.*(1-test); 
        test = fit <= ub;
        fit = fit.*test + ub.*(1-test); 
endfunction        
