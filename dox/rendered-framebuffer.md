# MulleCG Framebuffer Management

## Overview

MulleCG implements a sophisticated thread-safe framebuffer management system that allows sharing GPU resources between threads. This system enables efficient rendering in one thread and display in another (typically the main thread) without unnecessary texture recreation.

## The Offscreenbuffer Cycle

The framebuffer management system operates in a cyclical pattern:

1. **Generation**: A context creates and renders to a framebuffer
2. **Transfer**: The rendered framebuffer is made available to other threads
3. **Consumption**: Another thread (typically main UI thread) acquires and uses the framebuffer
4. **Recycling**: After use, the framebuffer is returned to the system
5. **Reuse**: The original context can repossess and reuse the framebuffer

This cycle minimizes the need to recreate GPU resources, improving performance while maintaining thread safety.

## Thread Considerations

Framebuffers in MulleCG have several important threading characteristics:

- Each framebuffer has a **home context** (the CGContext that created it)
- Framebuffers can temporarily transfer thread affinity during the cycle
- Resource tracking changes as framebuffers move between threads
- A framebuffer's underlying context never changes, only its thread affinity

## API Division

The framebuffer API is strictly divided into two parts:

### Producer API (Context Thread Only)

These methods must only be called by the thread that owns the context:

- **`provideRenderedFramebuffer:`**
  - Makes a framebuffer available to other threads
  - Removes the framebuffer from resource tracking
  - Includes a rendering barrier to ensure drawing is complete

- **`repossessRenderedFramebuffer`**
  - Reclaims a framebuffer from the scratch pool
  - Restores it as a tracked resource for the context

- **`recycleRenderedFramebuffer:`**
  - Context's internal version of recycling a framebuffer
  - Properly handles resource tracking

### Consumer API (Foreign Thread Only)

These methods must only be called by threads other than the context's own thread:

- **`acquireRenderedFramebuffer`**
  - Acquires a framebuffer provided by its home context
  - Temporarily transfers thread affinity

- **`recycleAcquiredRenderedFramebuffer:`**
  - Returns a previously acquired framebuffer
  - Attempts to place it in the scratch pool or queues for deletion

## Usage Example

Here's a typical usage pattern:

### Producer Thread (Context Thread)
```objc
// Create and render to a framebuffer
CGFramebuffer *framebuffer = [context framebufferWithSize:size 
                                             textureFlags:0 
                                           nameUTF8String:"MyRendering"];

// Set as current framebuffer and draw
[context bindFramebuffer:(struct CGContextFramebuffer){ .type = CGContextLayerFramebuffer, .handle = framebuffer }];
[context clearFramebuffer];
// ... perform drawing operations ...

// Make available to consumer threads
[context provideRenderedFramebuffer:framebuffer];
```

### Consumer Thread (UI Thread)
```objc
// Acquire the latest framebuffer
CGFramebuffer *framebuffer = [context acquireRenderedFramebuffer];
if (framebuffer)
{
    // Use framebuffer texture for display
    // ...
    
    // Return when done
    [context recycleAcquiredRenderedFramebuffer:framebuffer];
}
```

## Best Practices

1. **Strict API Separation**: Never call consumer API methods from the context thread or producer API methods from consumer threads
2. **Minimal Consumer Operations**: Consumers should only perform minimal operations on acquired framebuffers
3. **No Context Sharing**: Remember that framebuffers always belong to their home context, even when temporarily acquired
4. **Resource Tracking**: Be aware that resource tracking status changes as framebuffers move between threads
5. **Thread Safety**: The system handles thread safety internally - don't add your own locking around these operations

## Resource Management

The system automatically handles:
- Thread-safe reference counting
- Proper GPU resource cleanup
- Cross-thread resource transfer
- Framebuffer recycling for optimal performance

This structured approach prevents resource leaks and threading issues while maintaining high performance.