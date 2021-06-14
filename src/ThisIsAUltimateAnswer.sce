clear;

A = [
    0   0       1       0;
    0   0       0       1;
    0   -3.9801 -14.716 0;
    0   45.181  48.251  0;
];
B = [
    0;
    0;
    3.2929;
    -10.796;
];
C = [
    1   0   0   0;
    0   1   0   0;
];

disp("-----------------------------------------------------");

[ n, _ ] = size(A);

function ans = isPosDefMat(Q)
    [ n, _ ] = size(Q);

    ans = %t;
    for i=1:n
        if (real(spec(Q)(i)) <= 0) then
            ans = %f;
            break;
        end
    end
endfunction

function K = calcK(A, B, Q, R, Ksave)
    P = riccati(A, B * inv(R) * B', Q, 'c');
    K = - inv(R) * B' * P;
endfunction

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
    mat(1, 1) = 1; // 一行一列要素が負 => 非正定確定 → なので最初から正に矯正
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
    //mat(1, 1) = 1000000 * mat(1, 1); // 一行一列の要素が大きいとx1に効いてる
    mat(1, 1) = 99999999; // これが効く

endfunction

function mat = genRandMat(n)
    mat = round(genShfMat(n) .* rand(n, n)); // 整数行列
    //mat = genShfMat(n) .* rand(n, n); // 少数行列
                                        // どちらでも大して変わらないと思われる
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

function mat = genR(i)
    if (i == 1) then
        mat = [ 1 ];
    elseif (i == 2) then
        mat = [ 10 ];
    elseif (i == 3) then
        mat = [ 100 ];
    elseif (i == 4) then
        mat = [ 1000 ];
    else
       mat = [ 10000 ];
    end
endfunction

Q = eye(n, n);

R = [
    1
];

K = calcK(A, B, Q, R);

count_genQ = 1;
count_update = 1;
count_posdefmat = 1;
while 1
    Qn = genSymMat(n);

    if (isPosDefMat(Qn)) then
        if (modulo(count_posdefmat, 10000) == 0) then
            disp("乱数行列 生成回数=", count_genQ);
            disp("実対称正定行列 生成回数=", count_posdefmat);
            disp("-----------------------------------------------------");
        end
        count_posdefmat = count_posdefmat + 1;

        for i=1:5 // Rn = 1, 10, 100, 1000, 10000
            Rn = genR(i);
            Kn = calcK(A, B, Qn, Rn);
            if ( Kn(1)/Kn(2) >= K(1)/K(2) & 1000 >= Kn(1)) then
                Q = Qn;
                R = Rn;
                K = Kn;
    
                disp("乱数行列 生成回数=", count_genQ);
                disp("実対称正定行列 生成回数=", count_posdefmat);
                disp("最適値 更新回数=", count_update);
                disp("Q=", Q);
                disp("R=", R);
                disp("K=", K);
                disp("x1/x2 =", K(1)/K(2));
                disp("-----------------------------------------------------");
                count_update = count_update + 1;
            end
        end
    end
    count_genQ = count_genQ + 1;
end
