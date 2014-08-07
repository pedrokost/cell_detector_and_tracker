function pdf = mvnpdffast(x, mu,Sigma)
	r = chol(Sigma); 
    pdf = (2*pi)^(-size(x, 2)/2) * exp(-0.5 * sum(((x-repmat(mu, size(x, 1), 1))/r).^2,2)) / prod(diag(r)); 