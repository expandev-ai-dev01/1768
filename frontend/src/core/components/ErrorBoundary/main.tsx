import React, { Component, ErrorInfo, ReactNode } from 'react';
import { ErrorBoundaryProps, ErrorBoundaryState } from './types';

export class ErrorBoundary extends Component<ErrorBoundaryProps, ErrorBoundaryState> {
  public state: ErrorBoundaryState = {
    hasError: false,
  };

  public static getDerivedStateFromError(_: Error): ErrorBoundaryState {
    return { hasError: true };
  }

  public componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('Uncaught error:', error, errorInfo);
  }

  public render() {
    if (this.state.hasError || !this.props.children) {
      return (
        <div className="flex flex-col items-center justify-center min-h-screen bg-gray-100">
          <h1 className="text-2xl font-bold text-red-600">Something went wrong.</h1>
          <p className="text-gray-700">Please try refreshing the page.</p>
        </div>
      );
    }

    return this.props.children;
  }
}
