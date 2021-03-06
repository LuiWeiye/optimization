function [x,f_k, x_x, x_y, step_length, z] = conjugate_gradient(X, f, tol, N, beta, plot)

% example: [a,f_k,x,y] = conjugate_gradient([-1.2, 1], f, 1e-6, 300, 0.1);
% example: [a,f_k,x,y] = con_grad([1.2, 1.2], f, 1e-6, 300, 0.1);
% (100, 222 - normalized) (110, 236 - non normalized)
% 
% f = @(x, y) 100*(y - x.^2).^2 + (1-x).^2
% Inputs
% X: starting value (initial guess x_0)
% f: function
% tol: tolerance
% N: max iterations
% direction p_k = -grad(f(x_k))
% initial step size a_0 = 1
% step size a_k deteremined by backtracking
% x_k+1 = x_k + a_k*p_k
format long

if (nargin < 4) 
    tol = 1e-5;
end %if

k = 1; %initialize count
x = X;
MaxIter = N;
grad_f = Grad(x);
p_k = -1 * grad_f;
p_k = p_k/norm(p_k);
f_new = feval(f, x(1), x(2));

while (norm(p_k,2) > 1e-5*(1+abs(f_new))) && (k <= MaxIter) 
    
    a_k = 1;
    a_k = linesearch(a_k, beta, p_k, f, x);
    old_x = x;
    x = x + a_k * p_k;
    
    step_length(k,1:2) = [k, norm(x - old_x, 2)];
    
    if(x(1) < -512 || x(2) < -512 || x(1) > 512 || x(2) > 512)
       break;
    end
    f_new = feval(f, x(1), x(2));
    grad_f_new = Grad(x);
    
    PolakB = grad_f_new * (grad_f_new - grad_f)' / norm(grad_f, 2)^2;
    p_k = -1 * grad_f_new + PolakB * p_k;
    grad_f = grad_f_new;
 
    x_x(k) = x(1);
    x_y(k) = x(2);
    f_k(k) = f(x(1), x(2));
    z(k, 1:3) = [k, x];
    eps = norm(p_k * a_k, 2);
    k = k+1; 

end %while

%plot graph of function and path
if nargin > 5 && strcmp(plot,'plot')
        %rosenbrock_2d([X(1), X(2)],min(min(x_x, x_y)),max(max(x_x, x_y))) ;
        test_function([X(1), X(2)],min(min(x_x, x_y)),max(max(x_x, x_y))) ;
        hold on
        plot3(x_x, x_y, f_k, 'r');
        scatter3(x_x, x_y, f_k, 'b*');
end
end
%end con_grad

% Polak - Ribiere method and variants
function alpha = linesearch(a_k, beta, p_k, f, x)
 in = x + (a_k * p_k);
 c1 = 1e-4;
 c2 = 0.1; 
 % 0 < c1 < c2 < 0.5 stronger wolfe condition
 
 while  feval(f, in(1), in(2)) > (feval(f, x(1), x(2)) + c1 * a_k * (p_k' * p_k))
    %while Grad(in)' * p_k > c2 * grad_f' * p_k
        a_k = beta * a_k;
        in = x + a_k * p_k;
    %end
 end
 alpha = a_k;
end

function out = Grad(x_k)
%f_grad = @(x,y) [2*x - 400*x*(- x^2 + y) - 2, - 200*x^2 + 200*y];
f_grad = @(x,y) [(x*sign(y - x + 47)*cos(abs(y - x + 47)^(1/2)))/(2*abs(y - x + 47)^(1/2)) - sin(abs(y - x + 47)^(1/2)) - (sign(x/2 + y + 47)*cos(abs(x/2 + y + 47)^(1/2))*(y + 47))/(4*abs(x/2 + y + 47)^(1/2)), ...
    - sin(abs(x/2 + y + 47)^(1/2)) - (x*sign(y - x + 47)*cos(abs(y - x + 47)^(1/2)))/(2*abs(y - x + 47)^(1/2)) - (sign(x/2 + y + 47)*cos(abs(x/2 + y + 47)^(1/2))*(y + 47))/(2*abs(x/2 + y + 47)^(1/2))];
out = f_grad(x_k(1), x_k(2));
end


