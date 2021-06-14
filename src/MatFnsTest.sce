clear;
function random = genRand()
    random = rand(1) > 0.5;
endfunction

function sig = genSig()
    if genRand() then
        sig = 1
    else
        sig = -1
    end
endfunction

function mat = genRandSigMat(n)
    for i=1:n
        for j=1:n
            mat(i, j) = genSig();
        end
    end
endfunction

function num = genShf()
    r = rand(1);
    if (r >= 7.5) then
        num = 10000;
    elseif (r >= 0.5) then
        num = 1000;
    elseif (r >= 0.25) then
        num = 100;
    else
        num = 10;
    end
endfunction

function mat = genShfMat(n)
    for i=1:n
        for j=1:n
            mat(i, j) = genShf();
        end
    end
endfunction

function mat = genRandMat(n)
    mat = round(genShfMat(n) .* rand(n, n)); // 整数行列
    //mat = genShfMat(n) .* rand(n, n); // 少数行列
endfunction

function mat = genSymMat(n)
    mat = triu(genRandSigMat(n) .* genRandMat(n));
    mat = mat + [
            0 0 0 0;
            1 0 0 0;
            1 1 0 0;
            1 1 1 0;
        ] .* mat';
endfunction

n = 4;
disp(genSymMat(4));
