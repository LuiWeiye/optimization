function [x,f_k, x_x, x_y] = con_grad(X, f, tol, N, beta)

% example: [a,f_k,x,y] = steepest_descent([-1.2, 1], f, 1e-4, 6000, 0.5);
% example: [a,f_k,x,y] = steepest_descent([1.2, 1.2], f, 1e-4, 6000, 0.5);
% f = @(x, y) 100*(y - x.^2).^2 + (1-x).^2
% Inputs
% X: starting value (initial guess x_0)
% f: function
% tol: tolerance
% N: max iterations
% direction p_k = -grad(f(x_k))
% initial step size a_0 = 1
% step size a_k = grad(f(x_k))*p_k/(p_k^T * Q * p_k)
% x_k+1 = x_k + a_k*p_k
format long

if (nargin < 4) 
    tol = 1e-5;
end %if

k = 1; %initialize count
x = X;
MaxIter = N;
eps = 1;

while (eps > tol) && (k <= MaxIter)
    p_k = -1 * Grad(x);
    p_k = p_k/norm(p_k);
    
    a_k = 1;
    a_k = linesearch(a_k, beta, p_k, f, x);
    
    x = x + a_k * p_k;
    
    x_x(k) = x(1);
    x_y(k) = x(2);
    f_k(k) = f(x(1), x(2));    
    
    eps = norm(p_k * a_k, 2);
    k = k+1;
end %while

%plot graph of function and path
rosenbrock_2d([X(1), X(2)],min(min(x_x, x_y)),max(max(x_x, x_y))) ;
%test_function([X(1), X(2)],min(min(x_x, x_y)),max(max(x_x, x_y))) ;
hold on
scatter3(x_x, x_y, f_k, 'r.');



end
%end steepest_descent

%backtracking algorithm
function alpha = linesearch(a_k, beta, p_k, f, x)
 in = x + a_k * p_k;
 c1 = 1e-4;
 while feval(f, in(1), in(2)) > (feval(f, x(1), x(2)) + c1 * a_k * (p_k' * p_k))
    a_k = beta * a_k;
    in = x + a_k * p_k;
 end
 alpha = a_k;
end

function out = Grad(x_k)
f_grad = @(x,y) [2*x - 400*x*(- x^2 + y) - 2, - 200*x^2 + 200*y];
%f_grad = @(x,y) [(x*sign(y - x + 47)*cos(abs(y - x + 47)^(1/2)))/(2*abs(y - x + 47)^(1/2)) - sin(abs(y - x + 47)^(1/2)) - (sign(x/2 + y + 47)*cos(abs(x/2 + y + 47)^(1/2))*(y + 47))/(4*abs(x/2 + y + 47)^(1/2)), ...
%    - sin(abs(x/2 + y + 47)^(1/2)) - (x*sign(y - x + 47)*cos(abs(y - x + 47)^(1/2)))/(2*abs(y - x + 47)^(1/2)) - (sign(x/2 + y + 47)*cos(abs(x/2 + y + 47)^(1/2))*(y + 47))/(2*abs(x/2 + y + 47)^(1/2))];
out = f_grad(x_k(1), x_k(2));
end

