function [ ii ] = label_consecutive_numbers( a )
%LABEL_CONSECUTIVE_NUMBERS Assign a unique label for consecutive numbers in
%a vector. Copied from https://se.mathworks.com/matlabcentral/answers/34302-how-to-find-consecutive-numbers
%
%   Input
%       a: input vector, sorted
%   Output
%       ii: unique labels

t = diff(a) == 1;
y = [t,false];
x = xor(y,[false,t]);
ii = cumsum(~(x|y) + y.*x);

end