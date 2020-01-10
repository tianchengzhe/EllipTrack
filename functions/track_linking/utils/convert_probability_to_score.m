function [ score ] = convert_probability_to_score( prob )
%COMVERT_PROBABILITY_TO_SCORE Convert a probability to a score
%
%   Input
%       prob: probability
%   Output
%       score: converted score

score = log(prob) - log(1-prob);

end