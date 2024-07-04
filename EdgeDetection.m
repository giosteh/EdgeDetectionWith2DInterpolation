% classe che modella le routines di `edge detection`

classdef EdgeDetection
    properties
        Img (:,:)
        xg (1,:)
        yg (1,:)
    end

    methods
        % costruttore che istanzia l'immagine `Img`
        function obj = EdgeDetection(img)
            if nargin == 1
                sz = size(img);
                if length(sz) > 2
                    img = rgb2gray(img);
                end

                obj.Img = img;
                obj.xg = 1:sz(1);
                obj.yg = 1:sz(2);
            end
        end

        % metodo che restituisce un interpolante di `Img`
        function S = interpolate(obj, xx, yy, method)
            switch method
                case 'lagrange'
                    S = obj.lagrange2d(xx, yy);
                otherwise
                    F = griddedInterpolant({obj.xg, obj.yg}, double(obj.Img), method);
                    S = F({xx, yy});
            end
        end

        % metodo che restituisce un interpolante di Lagrange di grado 2
        function S = lagrange2d(obj, xx, yy)
            f = double(obj.Img);
            [rows, cols] = size(f);

            function grid = find_grid3x3(x, y)
                x_int = round(x);
                y_int = round(y);
                % riporto gli indici dentro l'immagine
                if x_int <= 1; x_int = 2; end
                if y_int <= 1; y_int = 2; end
                if x_int >= rows; x_int = rows-1; end
                if y_int >= cols; y_int = cols-1; end

                x_grid = [x_int-1, x_int, x_int+1];
                y_grid = [y_int-1, y_int, y_int+1];

                grid = {x_grid, y_grid};
            end

            function interp = evaluate(x, y)
                grid = find_grid3x3(x, y);
                xi = grid{1}; yi = grid{2};

                interp = 0;
                for r = 1:3
                    fx_interp = 0;
                    for s = 1:3
                        term = f(xi(s), yi(r));
                        for t = 1:3
                            if s ~= t
                                term = term * ((x - xi(t)) / (xi(s) - xi(t)));
                            end
                        end
                        fx_interp = fx_interp + term;
                    end

                    term = fx_interp;
                    for s = 1:3
                        if r ~= s
                            term = term * ((y - yi(s)) / (yi(r) - yi(s)));
                        end
                    end
                    interp = interp + term;
                end
            end

            % valutazione della superficie interpolante
            m = size(xx, 2);
            n = size(yy, 2);
            S = zeros(m, n);

            for i = 1:m
                for j = 1:n
                    S(i, j) = evaluate(xx(i), yy(j));
                end
            end
        end
        
        % metodo che calcola l'immagine "gradiente"
        function G = gradient(obj, method, order, h)
            x = obj.xg;
            y = obj.yg;
            I = cell(1, 9);

            % calcolo i valori dell'interpolante necessari
            I{1} = obj.interpolate(x, y, method);

            I{2} = obj.interpolate(x+h, y, method);
            I{3} = obj.interpolate(x, y+h, method);
            I{4} = obj.interpolate(x-h, y, method);
            I{5} = obj.interpolate(x, y-h, method);

            I{6} = obj.interpolate(x+2*h, y, method);
            I{7} = obj.interpolate(x, y+2*h, method);
            I{8} = obj.interpolate(x-2*h, y, method);
            I{9} = obj.interpolate(x, y-2*h, method);

            switch order
                % con differenze finite di ordine #1
                case '#1'
                    FG = (I{2} + I{3} - 2.*I{1}) ./ h;
                    BG = (2.*I{1} - I{4} - I{5}) ./ h;

                    G = [FG(1:end-1, :); BG(end, :)];
                    G = [G(:, 1:end-1), BG(:, end)];
                    
                % con differenze finite di ordine #2
                case '#2'
                    FGx = (4.*I{2} - I{6} - 3.*I{1});
                    FGy = (4.*I{3} - I{7} - 3.*I{1});
                    BGx = (3.*I{1} + I{8} - 4.*I{4});
                    BGy = (3.*I{1} + I{9} - 4.*I{5});

                    FG = (FGx + FGy) ./ (2*h);
                    BG = (BGx + BGy) ./ (2*h);

                    G = [FG(1:end-2, :); BG(end-1:end, :)];
                    G = [G(:, 1:end-2), BG(:, end-1:end)];

                otherwise
                    error('Utilizzare ordine #1 o #2.');
            end
        end

        % metodo che binarizza l'immagine `grad`
        function B = binarize(~, grad, thresh)
            scaled = (grad - min(min(grad))) ./ (max(max(grad)) - min(min(grad)));
            B = scaled >= thresh;
        end

    end
end
