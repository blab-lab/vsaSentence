function [dataPaths] = get_dataPaths_vsaSentence(session)
%GET_DATAPATHS_VSASENTENCE2  Get datapaths for the vsaSentence2 experiment.
%SESSION can be 'adapt' or 'null' (or leave blank for the parent directory)
% Sara Beach 1-2024

if nargin < 1, session = []; end

svec = [68 194 195 234 248 272 301 306 322 327 330 331 336 342 343 344 347 348 349 350 357 361 376 385 387 388 390 392 416 419 422 427 440 443 450 453 461 475 502 600 601];

dataPaths = get_acoustLoadPaths('vsaSentence',svec,session);

end